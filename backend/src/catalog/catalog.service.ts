import { Inject, Injectable } from '@nestjs/common';
import { Pool } from 'pg';
import { PG_POOL } from '../database/database.module';

export interface CarMake {
  id: number;
  name: string;
}

export interface CarModel {
  id: number;
  make_id: number;
  name: string;
}

export interface CarGeneration {
  id: number;
  model_id: number;
  name: string;
  year_from: number | null;
  year_to: number | null;
}

@Injectable()
export class CatalogService {
  constructor(@Inject(PG_POOL) private readonly pool: Pool) {}

  async getMakes(): Promise<CarMake[]> {
    const result = await this.pool.query<CarMake>(
      'SELECT id, name FROM car_makes ORDER BY name',
    );
    return result.rows;
  }

  async getModels(makeId: number): Promise<CarModel[]> {
    const result = await this.pool.query<CarModel>(
      'SELECT id, make_id, name FROM car_models WHERE make_id = $1 ORDER BY name',
      [makeId],
    );
    return result.rows;
  }

  async getGenerations(modelId: number): Promise<CarGeneration[]> {
    const result = await this.pool.query<CarGeneration>(
      'SELECT id, model_id, name, year_from, year_to FROM car_generations WHERE model_id = $1 ORDER BY year_from NULLS LAST',
      [modelId],
    );
    return result.rows;
  }
}
