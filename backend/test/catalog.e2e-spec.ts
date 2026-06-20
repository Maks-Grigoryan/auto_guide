import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('GET /catalog (e2e)', () => {
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

  it('GET /catalog/makes returns 200 array with a CIS make', async () => {
    const res = await request(app.getHttpServer())
      .get('/catalog/makes')
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    const names: string[] = (res.body as { name: string }[]).map((m) => m.name);
    const hasCisMake = names.some((n) => /lada|ваз/i.test(n));
    expect(hasCisMake).toBe(true);
  });

  it('GET /catalog/makes has Cache-Control: public, max-age=86400', async () => {
    await request(app.getHttpServer())
      .get('/catalog/makes')
      .expect(200)
      .expect('cache-control', 'public, max-age=86400');
  });

  it('GET /catalog/models?makeId=X returns 200 array with cache header', async () => {
    // ВАЗ (id=1) is always seeded with models — use it directly
    await request(app.getHttpServer())
      .get('/catalog/models')
      .query({ makeId: 1 })
      .expect(200)
      .expect('cache-control', 'public, max-age=86400')
      .then((res) => {
        expect(Array.isArray(res.body)).toBe(true);
      });
  });

  it('GET /catalog/models without makeId returns 400', async () => {
    await request(app.getHttpServer())
      .get('/catalog/models')
      .expect(400);
  });

  it('GET /catalog/models?makeId=abc returns 400', async () => {
    await request(app.getHttpServer())
      .get('/catalog/models')
      .query({ makeId: 'abc' })
      .expect(400);
  });

  it('GET /catalog/generations?modelId=X returns 200 array with cache header', async () => {
    // ВАЗ Приора (model id=1) is always seeded with generations — use it directly
    await request(app.getHttpServer())
      .get('/catalog/generations')
      .query({ modelId: 1 })
      .expect(200)
      .expect('cache-control', 'public, max-age=86400')
      .then((res) => {
        expect(Array.isArray(res.body)).toBe(true);
      });
  });

  it('GET /catalog/generations without modelId returns 400', async () => {
    await request(app.getHttpServer())
      .get('/catalog/generations')
      .expect(400);
  });

  it('GET /catalog/part-categories returns 200 array', async () => {
    const res = await request(app.getHttpServer())
      .get('/catalog/part-categories')
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /catalog/part-categories has Cache-Control: public, max-age=86400', async () => {
    await request(app.getHttpServer())
      .get('/catalog/part-categories')
      .expect(200)
      .expect('cache-control', 'public, max-age=86400');
  });

  it('GET /catalog/service-categories returns 200 array containing «Развал-схождение»', async () => {
    const res = await request(app.getHttpServer())
      .get('/catalog/service-categories')
      .expect(200);

    expect(Array.isArray(res.body)).toBe(true);
    const names: string[] = (res.body as { name: string }[]).map((c) => c.name);
    expect(names).toContain('Развал-схождение');
  });

  it('GET /catalog/service-categories has Cache-Control: public, max-age=86400', async () => {
    await request(app.getHttpServer())
      .get('/catalog/service-categories')
      .expect(200)
      .expect('cache-control', 'public, max-age=86400');
  });
});
