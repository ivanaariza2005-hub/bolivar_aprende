import request from 'supertest';
import { app } from '../src/app.js';
import { disconnectDatabase, resetDatabase, sampleOffer } from './helpers.js';

const api = request(app);
const validUser = {
  fullName: 'Andres Montes',
  email: 'andres.montes@example.com',
  password: 'Bolivar2026',
  passwordConfirmation: 'Bolivar2026',
};

let token;
let otherToken;

const authenticate = async (user) => {
  const response = await api.post('/api/auth/register').send(user);
  return response.body.token;
};

beforeEach(async () => {
  await resetDatabase();
  token = await authenticate(validUser);
  otherToken = await authenticate({
    ...validUser,
    fullName: 'Laura Pineda',
    email: 'laura.pineda@example.com',
  });
});

afterAll(disconnectDatabase);

describe('POST /api/offers', () => {
  it('crea una oferta y la devuelve con isSaved en false', async () => {
    const response = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer());

    expect(response.status).toBe(201);
    expect(response.body.data).toMatchObject({
      title: sampleOffer().title,
      type: 'job',
      municipality: 'Cartagena',
      isSaved: false,
    });
    expect(typeof response.body.data.id).toBe('string');
  });

  it('exige autenticacion', async () => {
    const response = await api.post('/api/offers').send(sampleOffer());

    expect(response.status).toBe(401);
  });

  it('rechaza un municipio fuera de Bolívar', async () => {
    const response = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer({ municipality: 'Bogota' }));

    expect(response.status).toBe(400);
    expect(response.body.error.details).toEqual(
      expect.arrayContaining([expect.objectContaining({ field: 'municipality' })]),
    );
  });

  it('rechaza un tipo invalido', async () => {
    const response = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer({ type: 'internship' }));

    expect(response.status).toBe(400);
    expect(response.body.error.details).toEqual(
      expect.arrayContaining([expect.objectContaining({ field: 'type' })]),
    );
  });

  it('rechaza una descripción demasiado corta', async () => {
    const response = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer({ description: 'Muy corta' }));

    expect(response.status).toBe(400);
  });
});

describe('GET /api/offers', () => {
  beforeEach(async () => {
    await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer());
    await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(
        sampleOffer({
          title: 'Beca de excelencia para pregrado',
          description:
            'Cobertura del cien por ciento de la matricula para estudiantes destacados del departamento.',
          type: 'academic',
          institution: 'Universidad de Cartagena',
          municipality: 'Magangué',
          modality: 'hybrid',
        }),
      );
  });

  it('lista todas las ofertas ordenadas por fecha descendente', async () => {
    const response = await api.get('/api/offers').set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.total).toBe(2);
    expect(response.body.data[0].createdAt >= response.body.data[1].createdAt).toBe(true);
  });

  it('filtra por tipo', async () => {
    const response = await api
      .get('/api/offers')
      .query({ type: 'academic' })
      .set('Authorization', `Bearer ${token}`);

    expect(response.body.total).toBe(1);
    expect(response.body.data[0].type).toBe('academic');
  });

  it('filtra por municipio', async () => {
    const response = await api
      .get('/api/offers')
      .query({ municipality: 'Cartagena' })
      .set('Authorization', `Bearer ${token}`);

    expect(response.body.total).toBe(1);
    expect(response.body.data[0].municipality).toBe('Cartagena');
  });

  it('busca por texto en título, institución y descripción', async () => {
    const response = await api
      .get('/api/offers')
      .query({ q: 'beca' })
      .set('Authorization', `Bearer ${token}`);

    expect(response.body.total).toBe(1);
    expect(response.body.data[0].title).toContain('Beca');
  });

  it('combina filtros de tipo y municipio', async () => {
    const response = await api
      .get('/api/offers')
      .query({ type: 'job', municipality: 'Magangué' })
      .set('Authorization', `Bearer ${token}`);

    expect(response.body.total).toBe(0);
  });
});

describe('GET /api/offers/:id', () => {
  it('devuelve el detalle de una oferta existente', async () => {
    const created = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer());

    const response = await api
      .get(`/api/offers/${created.body.data.id}`)
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(200);
    expect(response.body.data.id).toBe(created.body.data.id);
  });

  it('devuelve 404 cuando la oferta no existe', async () => {
    const response = await api
      .get('/api/offers/11111111-1111-4111-8111-111111111111')
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(404);
    expect(response.body.error.code).toBe('NOT_FOUND');
  });

  it('devuelve 400 con un identificador invalido', async () => {
    const response = await api.get('/api/offers/abc').set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(400);
  });
});

describe('PUT /api/offers/:id', () => {
  it('actualiza todos los campos de la oferta', async () => {
    const created = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer());

    const response = await api
      .put(`/api/offers/${created.body.data.id}`)
      .set('Authorization', `Bearer ${token}`)
      .send(
        sampleOffer({
          title: 'Coordinador de operaciones portuarias',
          modality: 'hybrid',
          municipality: 'Turbaco',
        }),
      );

    expect(response.status).toBe(200);
    expect(response.body.data).toMatchObject({
      title: 'Coordinador de operaciones portuarias',
      modality: 'hybrid',
      municipality: 'Turbaco',
    });
  });

  it('devuelve 404 al actualizar una oferta inexistente', async () => {
    const response = await api
      .put('/api/offers/11111111-1111-4111-8111-111111111111')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer());

    expect(response.status).toBe(404);
  });
});

describe('DELETE /api/offers/:id', () => {
  it('elimina la oferta y la quita del listado', async () => {
    const created = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer());

    const deleteResponse = await api
      .delete(`/api/offers/${created.body.data.id}`)
      .set('Authorization', `Bearer ${token}`);

    expect(deleteResponse.status).toBe(204);

    const listResponse = await api.get('/api/offers').set('Authorization', `Bearer ${token}`);
    expect(listResponse.body.total).toBe(0);
  });

  it('devuelve 404 al eliminar una oferta inexistente', async () => {
    const response = await api
      .delete('/api/offers/11111111-1111-4111-8111-111111111111')
      .set('Authorization', `Bearer ${token}`);

    expect(response.status).toBe(404);
  });

  it('mantiene el token del otro usuario operativo tras la eliminacion', async () => {
    const created = await api
      .post('/api/offers')
      .set('Authorization', `Bearer ${token}`)
      .send(sampleOffer());

    await api
      .delete(`/api/offers/${created.body.data.id}`)
      .set('Authorization', `Bearer ${token}`);

    const response = await api.get('/api/offers').set('Authorization', `Bearer ${otherToken}`);
    expect(response.status).toBe(200);
  });
});
