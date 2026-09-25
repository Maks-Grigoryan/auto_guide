import { Inject, Injectable } from '@nestjs/common';
import { Pool } from 'pg';

import { AI_PG_POOL } from '../../database/database.module';
import { LlmTool } from '../llm/llm-provider';

/**
 * Everything the server knows about the request and the model does not choose.
 *
 * Location and car live here rather than in a tool's arguments on purpose. If
 * the model could pass them, a prompt could talk it into searching another city
 * or another person's car. It cannot pass what it never sees.
 */
export interface ToolContext {
  lat: number;
  lng: number;
  makeId?: number;
  modelId?: number;
  generationId?: number;
}

/** A part the assistant found. The server turns these into chat cards. */
export interface FoundPart {
  partId: number;
  title: string;
  brand: string | null;
  oemNumber: string | null;
  price: number | null;
  inStock: boolean;
  vendorId: number;
  vendorName: string;
  distanceM: number;
}

export interface ToolResult {
  /** JSON handed back to the model. */
  payload: unknown;
  /** Parts to attach to the reply as cards. Never produced by the model. */
  parts?: FoundPart[];
}

const MAX_RADIUS_M = 50000;
const DEFAULT_RADIUS_M = 10000;
const MAX_ROWS = 10;

/**
 * The complete list of things the assistant can do.
 *
 * It is short by design. This is the hardest of the three locks on the data:
 * not a rule the model is asked to follow, but the absence of any other verb.
 * No tool writes, none reads accounts, none reaches the internet — so there is
 * nothing to talk it into.
 */
export const AI_TOOLS: LlmTool[] = [
  {
    name: 'resolve_car',
    description:
      'Find a car make and model by name when the user mentions one, e.g. ' +
      '"приора", "camry", "Опель Астра". Use when the user names a car that ' +
      'is not the one already selected in the app.',
    parameters: {
      type: 'object',
      properties: {
        query: { type: 'string', description: 'Car name as the user wrote it' },
      },
      required: ['query'],
      additionalProperties: false,
    },
  },
  {
    name: 'list_part_categories',
    description:
      'List the part categories that exist in the catalogue. Call this before ' +
      'find_parts when you need a category id, so you filter by a category ' +
      'that really exists instead of guessing one.',
    parameters: {
      type: 'object',
      properties: {},
      additionalProperties: false,
    },
  },
  {
    name: 'find_parts',
    description:
      'Search for parts on sale near the user. Returns individual parts with ' +
      'price, stock and the shop selling them. The user location and car are ' +
      'supplied by the app — do not ask for them and do not pass them.',
    parameters: {
      type: 'object',
      properties: {
        categoryId: {
          type: 'integer',
          description: 'Category id from list_part_categories',
        },
        query: {
          type: 'string',
          description: 'Free text or an OEM number to match against parts',
        },
        radiusM: {
          type: 'integer',
          description: `Search radius in metres, max ${MAX_RADIUS_M}`,
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: 'list_service_categories',
    description: 'List the kinds of repair service that shops offer.',
    parameters: {
      type: 'object',
      properties: {},
      additionalProperties: false,
    },
  },
  {
    name: 'find_repair_shops',
    description:
      'Search for repair shops near the user, optionally offering one kind of ' +
      'service. Use when the problem needs a workshop rather than a part.',
    parameters: {
      type: 'object',
      properties: {
        serviceCategoryId: {
          type: 'integer',
          description: 'Service category id from list_service_categories',
        },
        radiusM: {
          type: 'integer',
          description: `Search radius in metres, max ${MAX_RADIUS_M}`,
        },
      },
      additionalProperties: false,
    },
  },
  {
    name: 'get_vendor',
    description:
      'Full details of one shop: address, phone, rating, opening hours.',
    parameters: {
      type: 'object',
      properties: {
        vendorId: { type: 'integer' },
      },
      required: ['vendorId'],
      additionalProperties: false,
    },
  },
];

@Injectable()
export class AiToolsService {
  constructor(@Inject(AI_PG_POOL) private readonly pool: Pool) {}

  /**
   * Runs one tool call.
   *
   * Arguments come from a language model, so nothing here trusts them: every
   * number goes through a clamp, every value through a parameterised query. The
   * SQL is written in this file and never assembled from the model's output.
   */
  async execute(
    name: string,
    args: Record<string, unknown>,
    context: ToolContext,
  ): Promise<ToolResult> {
    switch (name) {
      case 'resolve_car':
        return this.resolveCar(asString(args.query));
      case 'list_part_categories':
        return this.listCategories('part_categories');
      case 'list_service_categories':
        return this.listCategories('service_categories');
      case 'find_parts':
        return this.findParts(args, context);
      case 'find_repair_shops':
        return this.findRepairShops(args, context);
      case 'get_vendor':
        return this.getVendor(asInt(args.vendorId));
      default:
        // Reported to the model rather than thrown: a hallucinated tool name is
        // something it can recover from on the next turn.
        return { payload: { error: `Unknown tool: ${name}` } };
    }
  }

  private async resolveCar(query: string | null): Promise<ToolResult> {
    if (!query) return { payload: { matches: [] } };

    const result = await this.pool.query<{
      make_id: string;
      make_name: string;
      model_id: string | null;
      model_name: string | null;
    }>(
      `SELECT mk.id AS make_id, mk.name AS make_name,
              md.id AS model_id, md.name AS model_name
         FROM car_makes mk
         LEFT JOIN car_models md ON md.make_id = mk.id
        WHERE mk.name ILIKE $1 OR md.name ILIKE $1
        LIMIT 10`,
      [`%${query}%`],
    );

    return {
      payload: {
        matches: result.rows.map((row) => ({
          makeId: Number(row.make_id),
          makeName: row.make_name,
          modelId: row.model_id ? Number(row.model_id) : null,
          modelName: row.model_name,
        })),
      },
    };
  }

  private async listCategories(
    table: 'part_categories' | 'service_categories',
  ): Promise<ToolResult> {
    // The table name is not interpolated from anything the model said — it
    // comes from the switch above, which only ever passes these two literals.
    const result = await this.pool.query<{ id: string; name: string }>(
      `SELECT id, name FROM ${table} ORDER BY name`,
    );
    return {
      payload: {
        categories: result.rows.map((row) => ({
          id: Number(row.id),
          name: row.name,
        })),
      },
    };
  }

  private async findParts(
    args: Record<string, unknown>,
    context: ToolContext,
  ): Promise<ToolResult> {
    const result = await this.pool.query<{
      part_id: string;
      title: string;
      brand: string | null;
      oem_number: string | null;
      price: string | null;
      in_stock: boolean;
      vendor_id: string;
      vendor_name: string;
      distance_m: number;
    }>('SELECT * FROM search_parts_items($1,$2,$3,$4,$5,$6,$7,$8,$9)', [
      context.lat,
      context.lng,
      clampRadius(args.radiusM),
      context.makeId ?? null,
      context.modelId ?? null,
      context.generationId ?? null,
      asInt(args.categoryId),
      asString(args.query),
      MAX_ROWS,
    ]);

    const parts: FoundPart[] = result.rows.map((row) => ({
      partId: Number(row.part_id),
      title: row.title,
      brand: row.brand,
      oemNumber: row.oem_number,
      price: row.price === null ? null : Number(row.price),
      inStock: row.in_stock,
      vendorId: Number(row.vendor_id),
      vendorName: row.vendor_name,
      distanceM: Math.round(row.distance_m),
    }));

    // An empty result is an answer, not a failure. Saying so plainly is what
    // keeps the model from filling the silence with parts that do not exist.
    return {
      payload:
        parts.length > 0
          ? { found: parts.length, parts }
          : {
              found: 0,
              note:
                'No matching parts within the radius. Tell the user plainly ' +
                'and offer to widen the search or try another category. Do ' +
                'not invent parts, shops or prices.',
            },
      parts,
    };
  }

  private async findRepairShops(
    args: Record<string, unknown>,
    context: ToolContext,
  ): Promise<ToolResult> {
    const result = await this.pool.query<{
      vendor_id: string;
      name: string;
      phone: string | null;
      address: string | null;
      distance_m: number;
      service_count: string;
      min_price: string | null;
      rating: string | null;
    }>('SELECT * FROM search_repair($1,$2,$3,$4)', [
      context.lat,
      context.lng,
      clampRadius(args.radiusM),
      asInt(args.serviceCategoryId),
    ]);

    const shops = result.rows.slice(0, MAX_ROWS).map((row) => ({
      vendorId: Number(row.vendor_id),
      name: row.name,
      phone: row.phone,
      address: row.address,
      distanceM: Math.round(row.distance_m),
      serviceCount: Number(row.service_count),
      minPrice: row.min_price === null ? null : Number(row.min_price),
      rating: row.rating === null ? null : Number(row.rating),
    }));

    return {
      payload:
        shops.length > 0
          ? { found: shops.length, shops }
          : {
              found: 0,
              note:
                'No repair shops within the radius. Say so and offer to widen ' +
                'the search. Do not invent shops.',
            },
    };
  }

  private async getVendor(vendorId: number | null): Promise<ToolResult> {
    if (vendorId === null) return { payload: { error: 'vendorId is required' } };

    const result = await this.pool.query(
      `SELECT id, name, type, phone, address, rating, is_verified, hours
         FROM vendors WHERE id = $1`,
      [vendorId],
    );
    return { payload: result.rows[0] ?? { error: 'Vendor not found' } };
  }
}

/** Radius the model asked for, forced into what the database will accept. */
function clampRadius(value: unknown): number {
  const radius = asInt(value);
  if (radius === null) return DEFAULT_RADIUS_M;
  return Math.min(Math.max(radius, 100), MAX_RADIUS_M);
}

function asInt(value: unknown): number | null {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return Math.trunc(value);
  }
  if (typeof value === 'string' && /^-?\d+$/.test(value.trim())) {
    return Number.parseInt(value, 10);
  }
  return null;
}

function asString(value: unknown): string | null {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  // Capped: the model is quoting a user, and a user can paste anything.
  return trimmed.length > 0 ? trimmed.slice(0, 200) : null;
}
