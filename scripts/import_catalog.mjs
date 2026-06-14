#!/usr/bin/env node
// import_catalog.mjs — Idempotent upsert of car catalog and categories from CSV files.
// Uses parameterized pg.Pool inserts only (no string interpolation of CSV values into SQL).
// Usage: DATABASE_URL=postgres://... node scripts/import_catalog.mjs

import { createReadStream } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { createInterface } from 'readline';
import pg from 'pg';

const { Pool } = pg;
const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');
const SEED = resolve(ROOT, 'db/seed');

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function readCsv(filePath) {
  const rows = [];
  const rl = createInterface({ input: createReadStream(filePath), crlfDelay: Infinity });
  let headers = null;
  for await (const line of rl) {
    const trimmed = line.trim();
    if (!trimmed) continue;
    const cols = trimmed.split(',');
    if (!headers) { headers = cols; continue; }
    const row = {};
    headers.forEach((h, i) => { row[h] = (cols[i] ?? '').trim(); });
    rows.push(row);
  }
  return rows;
}

async function upsertMakesFromCsv(client, filePath) {
  const rows = await readCsv(filePath);
  // Track inserted IDs to avoid duplicate queries within this run
  const makeCache = new Map();   // name -> id
  const modelCache = new Map();  // `${makeId}:${modelName}` -> id

  for (const row of rows) {
    const makeName = row.make_name;
    const modelName = row.model_name;
    const genName = row.generation_name;
    const yearFrom = row.year_from ? parseInt(row.year_from, 10) : null;
    const yearTo = row.year_to ? parseInt(row.year_to, 10) : null;

    if (!makeName || !modelName) continue;

    // Upsert make
    let makeId = makeCache.get(makeName);
    if (!makeId) {
      const res = await client.query(
        `INSERT INTO car_makes (name) VALUES ($1)
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [makeName]
      );
      if (res.rows.length > 0) {
        makeId = res.rows[0].id;
      } else {
        const sel = await client.query('SELECT id FROM car_makes WHERE name = $1', [makeName]);
        makeId = sel.rows[0]?.id;
      }
      if (makeId) makeCache.set(makeName, makeId);
    }
    if (!makeId) continue;

    // Upsert model
    const modelKey = `${makeId}:${modelName}`;
    let modelId = modelCache.get(modelKey);
    if (!modelId) {
      const res = await client.query(
        `INSERT INTO car_models (make_id, name) VALUES ($1, $2)
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [makeId, modelName]
      );
      if (res.rows.length > 0) {
        modelId = res.rows[0].id;
      } else {
        const sel = await client.query(
          'SELECT id FROM car_models WHERE make_id = $1 AND name = $2',
          [makeId, modelName]
        );
        modelId = sel.rows[0]?.id;
      }
      if (modelId) modelCache.set(modelKey, modelId);
    }
    if (!modelId) continue;

    // Upsert generation (only if name is provided)
    if (genName) {
      await client.query(
        `INSERT INTO car_generations (model_id, name, year_from, year_to)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT DO NOTHING`,
        [modelId, genName, yearFrom, yearTo]
      );
    }
  }
}

async function upsertCategories(client, filePath) {
  const rows = await readCsv(filePath);
  const partCatCache = new Map();   // name -> id
  const svcCatCache = new Map();

  for (const row of rows) {
    const { category_type, name, parent_name } = row;
    if (!category_type || !name) continue;

    if (category_type === 'part') {
      let parentId = null;
      if (parent_name) {
        parentId = partCatCache.get(parent_name) ?? null;
      }
      const res = await client.query(
        `INSERT INTO part_categories (name, parent_id) VALUES ($1, $2)
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [name, parentId]
      );
      const id = res.rows[0]?.id ?? (await client.query(
        'SELECT id FROM part_categories WHERE name = $1', [name]
      )).rows[0]?.id;
      if (id) partCatCache.set(name, id);
    } else if (category_type === 'service') {
      const res = await client.query(
        `INSERT INTO service_categories (name) VALUES ($1)
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [name]
      );
      const id = res.rows[0]?.id ?? (await client.query(
        'SELECT id FROM service_categories WHERE name = $1', [name]
      )).rows[0]?.id;
      if (id) svcCatCache.set(name, id);
    }
  }
  return { partCatCache, svcCatCache };
}

async function main() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    console.log('Importing CIS makes...');
    await upsertMakesFromCsv(client, resolve(SEED, 'cis_makes.csv'));

    console.log('Importing vPIC makes...');
    await upsertMakesFromCsv(client, resolve(SEED, 'vpic_makes.csv'));

    console.log('Importing categories...');
    await upsertCategories(client, resolve(SEED, 'categories.csv'));

    await client.query('COMMIT');
    console.log('Catalog import complete.');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Import failed, rolled back:', err.message);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

main();
