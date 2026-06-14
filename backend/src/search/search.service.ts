import { Inject, Injectable } from '@nestjs/common';
import { Pool } from 'pg';
import { PG_POOL } from '../database/database.module';
import { SearchPartsDto } from './dto/search-parts.dto';

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
}

@Injectable()
export class SearchService {
  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  async searchParts(dto: SearchPartsDto): Promise<VendorSearchResult[]> {
    const { lat, lng, radius, makeId, modelId, categoryId, query } = dto;
    const result = await this.pool.query<VendorSearchResult>(
      'SELECT * FROM search_parts($1,$2,$3,$4,$5,$6,$7)',
      [
        lat,
        lng,
        radius,
        makeId ?? null,
        modelId ?? null,
        categoryId ?? null,
        query ?? null,
      ],
    );
    return result.rows;
  }
}
