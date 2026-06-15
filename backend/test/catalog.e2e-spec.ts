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
    const makesRes = await request(app.getHttpServer())
      .get('/catalog/makes')
      .expect(200);

    const makes = makesRes.body as { id: number; name: string }[];
    expect(makes.length).toBeGreaterThan(0);
    const makeId = makes[0].id;

    await request(app.getHttpServer())
      .get('/catalog/models')
      .query({ makeId })
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
    const makesRes = await request(app.getHttpServer())
      .get('/catalog/makes')
      .expect(200);

    const makes = makesRes.body as { id: number; name: string }[];
    const makeId = makes[0].id;

    const modelsRes = await request(app.getHttpServer())
      .get('/catalog/models')
      .query({ makeId })
      .expect(200);

    const models = modelsRes.body as { id: number; name: string }[];
    expect(models.length).toBeGreaterThan(0);
    const modelId = models[0].id;

    await request(app.getHttpServer())
      .get('/catalog/generations')
      .query({ modelId })
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
});
