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
});
