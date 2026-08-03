import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import * as request from 'supertest';
import { AppModule } from '../src/app.module';

describe('GET /vendors/:id (e2e)', () => {
  let app: INestApplication | undefined;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }));
    await app.init();
  });

  afterAll(async () => {
    await app?.close();
  });

  it('returns a complete vendor card', async () => {
    const response = await request(app!.getHttpServer())
      .get('/vendors/1')
      .expect(200);

    expect(response.body).toEqual(
      expect.objectContaining({
        id: '1',
        name: expect.any(String),
        type: expect.stringMatching(/^(parts_shop|repair_shop)$/),
        lat: expect.any(Number),
        lng: expect.any(Number),
        is_verified: expect.any(Boolean),
      }),
    );
  });

  it.each(['/vendors/0', '/vendors/-1', '/vendors/not-a-number'])(
    'rejects invalid id %s',
    async (path) => {
      await request(app!.getHttpServer()).get(path).expect(400);
    },
  );

  it('returns 404 when the vendor does not exist', async () => {
    await request(app!.getHttpServer()).get('/vendors/999999999').expect(404);
  });
});
