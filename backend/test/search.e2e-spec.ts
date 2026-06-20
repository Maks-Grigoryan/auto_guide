import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('GET /search/parts (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns 200 with >=5 vendors for Yerevan area', async () => {
    const res = await request(app.getHttpServer())
      .get('/search/parts')
      .query({ lat: 40.1872, lng: 44.5152, radius: 50000 })
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    expect((res.body as unknown[]).length).toBeGreaterThanOrEqual(5);
  });

  it('returns 400 when lat is missing', async () => {
    await request(app.getHttpServer())
      .get('/search/parts')
      .query({ lng: 44.5152, radius: 50000 })
      .expect(400);
  });

  it('returns 400 when lat is non-numeric', async () => {
    await request(app.getHttpServer())
      .get('/search/parts')
      .query({ lat: 'notanumber', lng: 44.5152, radius: 50000 })
      .expect(400);
  });

  const YEREVAN = { lat: 40.1872, lng: 44.5152, radius: 20000 };

  it('returns 400 when radius exceeds 100000 (DoS cap)', async () => {
    await request(app.getHttpServer())
      .get('/search/parts')
      .query({ ...YEREVAN, radius: 150000 })
      .expect(400);
  });

  it('accepts generationId and returns 200', async () => {
    const res = await request(app.getHttpServer())
      .get('/search/parts')
      .query({ ...YEREVAN, makeId: 1, generationId: 1 })
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
  });

  it('categoryId narrows results — brake category returns fewer vendors than no filter (8-arg fix regression)', async () => {
    const [all, brakes] = await Promise.all([
      request(app.getHttpServer())
        .get('/search/parts')
        .query({ ...YEREVAN })
        .expect(200),
      request(app.getHttpServer())
        .get('/search/parts')
        .query({ ...YEREVAN, categoryId: 1 })
        .expect(200),
    ]);

    expect(Array.isArray(all.body)).toBe(true);
    expect(Array.isArray(brakes.body)).toBe(true);
    // categoryId=1 (Тормоза) must return fewer vendors than the unfiltered call
    expect((brakes.body as unknown[]).length).toBeLessThan(
      (all.body as unknown[]).length,
    );
  });

  it('OEM query "192 16" (with space) returns the vendor holding oem 19216', async () => {
    const res = await request(app.getHttpServer())
      .get('/search/parts')
      .query({ ...YEREVAN, query: '192 16' })
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    const names = (res.body as Array<{ name: string }>).map((v) => v.name);
    expect(names).toContain('АвтоДетали Центр');
  });

  it('OEM query "192-16" (with dash) returns the same vendor as "192 16"', async () => {
    const res = await request(app.getHttpServer())
      .get('/search/parts')
      .query({ ...YEREVAN, query: '192-16' })
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    const names = (res.body as Array<{ name: string }>).map((v) => v.name);
    expect(names).toContain('АвтоДетали Центр');
  });

  it('makeId alone returns whole-make NULL-model fitment parts (PRT-03)', async () => {
    // makeId=1 is ВАЗ; seed inserts whole-make fitments (model_id NULL) for ВАЗ parts
    const res = await request(app.getHttpServer())
      .get('/search/parts')
      .query({ ...YEREVAN, makeId: 1 })
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    expect((res.body as unknown[]).length).toBeGreaterThanOrEqual(1);
  });
});

describe('GET /search/repair (e2e)', () => {
  let app: INestApplication;

  const YEREVAN = { lat: 40.1872, lng: 44.5152, radius: 50000 };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('returns 200 JSON array for Yerevan area', async () => {
    const res = await request(app.getHttpServer())
      .get('/search/repair')
      .query(YEREVAN)
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
  });

  it('returns 400 when lat is missing', async () => {
    await request(app.getHttpServer())
      .get('/search/repair')
      .query({ lng: 44.5152, radius: 50000 })
      .expect(400);
  });

  it('returns 400 when radius exceeds 100000 (DoS cap)', async () => {
    await request(app.getHttpServer())
      .get('/search/repair')
      .query({ lat: 40.1872, lng: 44.5152, radius: 150000 })
      .expect(400);
  });

  it('each returned row has type === "repair_shop" and numeric-string item_count', async () => {
    const res = await request(app.getHttpServer())
      .get('/search/repair')
      .query(YEREVAN)
      .expect(200);

    const rows = res.body as Array<{ type: string; item_count: string }>;
    expect(Array.isArray(rows)).toBe(true);
    for (const row of rows) {
      expect(row.type).toBe('repair_shop');
      expect(typeof row.item_count).toBe('string');
      expect(Number.isFinite(Number(row.item_count))).toBe(true);
    }
  });

  it('serviceCategoryId filter returns 200 array (subset by service category)', async () => {
    // First fetch service categories to get the «Развал-схождение» id dynamically
    const catRes = await request(app.getHttpServer())
      .get('/catalog/service-categories')
      .expect(200);

    const categories = catRes.body as Array<{ id: number; name: string }>;
    const razvalkaSkhod = categories.find((c) => c.name === 'Развал-схождение');
    expect(razvalkaSkhod).toBeDefined();

    const res = await request(app.getHttpServer())
      .get('/search/repair')
      .query({ ...YEREVAN, serviceCategoryId: razvalkaSkhod!.id })
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
  });

  it('returns 400 when lat is non-numeric', async () => {
    await request(app.getHttpServer())
      .get('/search/repair')
      .query({ lat: 'notanumber', lng: 44.5152, radius: 50000 })
      .expect(400);
  });
});
