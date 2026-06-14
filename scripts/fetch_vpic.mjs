#!/usr/bin/env node
// fetch_vpic.mjs — Fetch top market makes/models from NHTSA vPIC API and write vpic_makes.csv.
// If the API is unreachable, the committed db/seed/vpic_makes.csv is the offline fallback.
// Usage: node scripts/fetch_vpic.mjs [--output db/seed/vpic_makes.csv]

import { createWriteStream } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');

const OUTPUT = process.argv[3] ?? resolve(ROOT, 'db/seed/vpic_makes.csv');

const VPIC_BASE = 'https://vpic.nhtsa.dot.gov/api/vehicles';
const FORMAT = 'json';

// Top market makes relevant to Armenia/CIS (US-market subset from vPIC)
const TARGET_MAKES = [
  'Toyota', 'Hyundai', 'Kia', 'Mercedes-Benz', 'BMW', 'Audi',
  'Volkswagen', 'Nissan', 'Mazda', 'Subaru', 'Honda', 'Mitsubishi',
  'Lexus', 'Ford', 'Chevrolet', 'Opel', 'Skoda', 'Renault',
  'Peugeot', 'Volvo', 'Jeep', 'Land Rover', 'Porsche',
  'Infiniti', 'Acura', 'Genesis', 'Haval', 'Chery', 'Geely',
];

async function fetchJson(url) {
  const res = await fetch(url, { signal: AbortSignal.timeout(10000) });
  if (!res.ok) throw new Error(`HTTP ${res.status} for ${url}`);
  return res.json();
}

async function getModelsForMake(makeName) {
  const url = `${VPIC_BASE}/GetModelsForMake/${encodeURIComponent(makeName)}?format=${FORMAT}`;
  const data = await fetchJson(url);
  return (data.Results ?? []).map(r => r.Model_Name).filter(Boolean);
}

async function main() {
  console.log('Fetching vPIC data for target makes...');
  const rows = [['make_name', 'model_name', 'generation_name', 'year_from', 'year_to']];

  for (const make of TARGET_MAKES) {
    try {
      const models = await getModelsForMake(make);
      // vPIC does not return generation/year data per-model; use empty placeholders
      for (const model of models.slice(0, 10)) {
        rows.push([make, model, '', '', '']);
      }
      console.log(`  ${make}: ${models.length} models`);
    } catch (err) {
      console.warn(`  WARN: skipped ${make} — ${err.message}`);
    }
  }

  const csv = rows.map(r => r.map(v => `${v}`).join(',')).join('\n') + '\n';
  const ws = createWriteStream(OUTPUT);
  ws.write(csv);
  ws.end();
  console.log(`Written: ${OUTPUT} (${rows.length - 1} data rows)`);
}

main().catch(err => {
  console.error('fetch_vpic failed:', err.message);
  console.error('The committed db/seed/vpic_makes.csv will be used as offline fallback.');
  process.exit(1);
});
