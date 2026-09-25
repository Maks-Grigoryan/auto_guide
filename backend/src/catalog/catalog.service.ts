import { Inject, Injectable } from '@nestjs/common';
import { Pool } from 'pg';
import { PG_POOL } from '../database/database.module';

export interface PartCategory {
  id: number;
  name: string;
  parent_id: number | null;
}

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

export interface ServiceCategory {
  id: number;
  name: string;
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

  async getPartCategories(lang?: string): Promise<PartCategory[]> {
    const name = localisedName(lang);
    const result = await this.pool.query<PartCategory>(
      `SELECT id, ${name} AS name, parent_id
         FROM part_categories
        ORDER BY ${name}`,
    );
    return result.rows;
  }

  async getGenerations(
    modelId: number,
    lang?: string,
  ): Promise<CarGeneration[]> {
    const result = await this.pool.query<CarGeneration>(
      `SELECT id, model_id, ${localisedName(lang)} AS name, year_from, year_to
         FROM car_generations
        WHERE model_id = $1
        ORDER BY year_from NULLS LAST`,
      [modelId],
    );
    return result.rows;
  }

  async getServiceCategories(lang?: string): Promise<ServiceCategory[]> {
    const name = localisedName(lang);
    const result = await this.pool.query<ServiceCategory>(
      `SELECT id, ${name} AS name FROM service_categories ORDER BY ${name}`,
    );
    return result.rows;
  }
}

/**
 * The SQL expression yielding a row's name in [lang].
 *
 * A column name cannot be a bound parameter, so this is the one place where
 * text reaches a query uninterpolated. The switch is what makes that safe:
 * only these three literals can ever get into the SQL, whatever arrives as
 * `lang`. Building the identifier out of the input would be an injection.
 *
 * COALESCE falls back to the base name, so a category added after migration
 * 013 with no translations yet still appears in every locale rather than as an
 * empty row.
 */
function localisedName(lang?: string): string {
  switch (lang) {
    case 'hy':
      return 'COALESCE(name_hy, name)';
    case 'en':
      return 'COALESCE(name_en, name)';
    default:
      // Russian is the base column, and the fallback for anything unexpected.
      return 'name';
  }
}
