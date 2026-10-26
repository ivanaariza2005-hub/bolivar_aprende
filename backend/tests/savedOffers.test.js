import request from 'supertest';
import { app } from '../src/app.js';
import { disconnectDatabase, resetDatabase, sampleOffer } from './helpers.js';

const api = request(app);
const validUser = {
  fullName: 'Juliana Rios',
  email: 'juliana.rios@example.com',
  password: 'Bolivar2026',
  passwordConfirmation: 'Bolivar2026',
};

let token;
let otherToken;
let offerId;

const authenticate = async (user) => {
  const response = await api.post('/api/auth/register').send(user);
  return response.body.token;
};

beforeEach(async () => {
  await resetDatabase();
  token = await authenticate(validUser);
  otherToken = await authenticate({
    ...validUser,
    fullName: 'Mario Salas',
    email: 'mario.salas@example.com',
  });

  const created = await api
    .post('/api/offers')
    .set('Authorization', `Bearer ${token}`)
    .send(sampleOffer());
  offerId = created.body.data.id;
});

afterAll(disconnectDatabase);

describe('POST /api/offers/:id/save', () => {
  it('guarda la oferta para el usuario autenticado', async () => {
    const response = await api
      .post(`/api/offers/${offerId}/save`)
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.data).toEqual({ offerId, saved: true });

    const detail = await api
      .get(`/api/offers/${offerId}`)
      .set('Authorization', `Bearer ${token}`);
    expect(detail.body.data.isSaved).toBe(true);
  });

  it('es idempotente al guardar dos veces', async () => {
    await api.post(`/api/offers/${offerId}/save`).set('Authorization', `Bearer ${token}`);
    const response = await api
      .post(`/api/offers/${offerId}/save`)
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.data.saved).toBe(true);
  });

  it('devuelve 404 cuando la oferta no existe', async () => {
    const response = await api
      .post('/api/offers/11111111-1111-4111-8111-111111111111/save')
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(404);
  });
});

describe('DELETE /api/offers/:id/save', () => {
  it('desguarda la oferta', async () => {
    await api.post(`/api/offers/${offerId}/save`).set('Authorization', `Bearer ${token}`);

    const response = await api
      .delete(`/api/offers/${offerId}/save`)
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.data).toEqual({ offerId, saved: false });

    const detail = await api
      .get(`/api/offers/${offerId}`)
      .set('Authorization', `Bearer ${token}`);
    expect(detail.body.data.isSaved).toBe(false);
  });

  it('es idempotente al desguardar una oferta no guardada', async () => {
    const response = await api
      .delete(`/api/offers/${offerId}/save`)
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.data.saved).toBe(false);
  });
});

describe('GET /api/offers?saved=true', () => {
  it('devuelve solo las ofertas guardadas por el usuario', async () => {
    await api.post(`/api/offers/${offerId}/save`).set('Authorization', `Bearer ${token}`);

    const response = await api
      .get('/api/offers')
      .query({ saved: 'true' })
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.total).toBe(1);
    expect(response.body.data[0].id).toBe(offerId);
    expect(response.body.data[0].isSaved).toBe(true);
  });

  it('no mezcla las ofertas guardadas entre usuarios', async () => {
    await api.post(`/api/offers/${offerId}/save`).set('Authorization', `Bearer ${token}`);

    const otherUserResponse = await api
      .get('/api/offers')
      .query({ saved: 'true' })
      .set('Authorization', `Bearer ${otherToken}`);

    expect(otherUserResponse.body.total).toBe(0);

    const otherUserDetail = await api
      .get(`/api/offers/${offerId}`)
      .set('Authorization', `Bearer ${otherToken}`);
    expect(otherUserDetail.body.data.isSaved).toBe(false);
  });
});
