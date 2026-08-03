import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import { Pool } from 'pg';
import { PG_POOL } from '../database/database.module';

export interface VendorDetail {
  id: string;
  name: string;
  type: 'parts_shop' | 'repair_shop';
  phone: string | null;
  address: string | null;
  lat: number;
  lng: number;
  rating: string | null;
  is_verified: boolean;
  hours: Record<string, string> | null;
}

@Injectable()
export class VendorsService {
  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  async getById(id: number): Promise<VendorDetail> {
    const result = await this.pool.query<VendorDetail>(
      `SELECT id::text AS id, name, type, phone, address,
              ST_Y(location::geometry) AS lat,
              ST_X(location::geometry) AS lng,
              rating, is_verified, hours
       FROM vendors
       WHERE id = $1`,
      [id],
    );

    const vendor = result.rows[0];
    if (!vendor) {
      throw new NotFoundException('Vendor not found');
    }
    return vendor;
  }
}
