import { Inject, Injectable } from '@nestjs/common';
import { Pool } from 'pg';
import { PG_POOL } from '../database/database.module';
import { SearchPartsDto } from './dto/search-parts.dto';
import { SearchRepairDto } from './dto/search-repair.dto';

export interface VendorSearchResult {
  vendor_id: string;
  name: string;
  type: string;
  phone: string | null;
  address: string | null;
  lat: number;
  lng: number;
  distance_m: number;
  item_count: string;
  min_price: string | null;
  rating: string | null;
}

@Injectable()
export class SearchService {
  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  async searchParts(dto: SearchPartsDto): Promise<VendorSearchResult[]> {
    const { lat, lng, radius, makeId, modelId, generationId, categoryId, query } = dto;
    const result = await this.pool.query<VendorSearchResult>(
      'SELECT * FROM search_parts($1,$2,$3,$4,$5,$6,$7,$8)',
      [
        lat,
        lng,
        radius,
        makeId ?? null,
        modelId ?? null,
        generationId ?? null,
        categoryId ?? null,
        query ?? null,
      ],
    );
    return result.rows;
  }

  async searchRepair(dto: SearchRepairDto): Promise<VendorSearchResult[]> {
    const result = await this.pool.query<VendorSearchResult>(
      `SELECT vendor_id, name, 'repair_shop' AS type, phone, address, lat, lng,
              distance_m, service_count AS item_count, min_price, rating
       FROM search_repair($1,$2,$3,$4)`,
      [dto.lat, dto.lng, dto.radius, dto.serviceCategoryId ?? null],
    );
    return result.rows;
  }
}
