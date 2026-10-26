import jwt from 'jsonwebtoken';
import request from 'supertest';
import { app } from '../src/app.js';
import { disconnectDatabase, resetDatabase } from './helpers.js';

const api = request(app);

const validUser = {
  fullName: 'Camila Torres',
  email: 'camila.torres@example.com',
  password: 'Bolivar2026',
  passwordConfirmation: 'Bolivar2026',
};

beforeEach(resetDatabase);
afterAll(disconnectDatabase);

describe('POST /api/auth/register', () => {
  it('crea la cuenta y devuelve token y usuario sin datos sensibles', async () => {
    const response = await api.post('/api/auth/register').send(validUser);

    expect(response.status).toBe(201);
    expect(typeof response.body.token).toBe('string');
    expect(response.body.user).toMatchObject({
      fullName: validUser.fullName,
      email: validUser.email,
    });
    expect(response.body.user).not.toHaveProperty('passwordHash');
  });

  it('rechaza un correo ya registrado', async () => {
    await api.post('/api/auth/register').send(validUser);
    const response = await api.post('/api/auth/register').send(validUser);

    expect(response.status).toBe(409);
    expect(response.body.error.code).toBe('EMAIL_TAKEN');
  });

  it('rechaza contrasenas que no coinciden', async () => {
    const response = await api
      .post('/api/auth/register')
      .send({ ...validUser, passwordConfirmation: 'OtraClave2026' });

    expect(response.status).toBe(400);
    expect(response.body.error.code).toBe('VALIDATION_ERROR');
    expect(response.body.error.details).toEqual(
      expect.arrayContaining([expect.objectContaining({ field: 'passwordConfirmation' })]),
    );
  });

  it('rechaza un correo invalido', async () => {
    const response = await api
      .post('/api/auth/register')
      .send({ ...validUser, email: 'correo-invalido' });

    expect(response.status).toBe(400);
    expect(response.body.error.details).toEqual(
      expect.arrayContaining([expect.objectContaining({ field: 'email' })]),
    );
  });

  it('rechaza una contraseña débil', async () => {
    const response = await api
      .post('/api/auth/register')
      .send({ ...validUser, password: 'corta', passwordConfirmation: 'corta' });

    expect(response.status).toBe(400);
    expect(response.body.error.details).toEqual(
      expect.arrayContaining([expect.objectContaining({ field: 'password' })]),
    );
  });
});

describe('POST /api/auth/login', () => {
  beforeEach(async () => {
    await api.post('/api/auth/register').send(validUser);
  });

  it('devuelve token con credenciales correctas', async () => {
    const response = await api
      .post('/api/auth/login')
      .send({ email: validUser.email, password: validUser.password });

    expect(response.status).toBe(200);
    expect(typeof response.body.token).toBe('string');
    expect(response.body.user.email).toBe(validUser.email);
  });

  it('rechaza contraseña incorrecta', async () => {
    const response = await api
      .post('/api/auth/login')
      .send({ email: validUser.email, password: 'Incorrecta2026' });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('INVALID_CREDENTIALS');
  });

  it('rechaza un correo inexistente', async () => {
    const response = await api
      .post('/api/auth/login')
      .send({ email: 'nadie@example.com', password: 'Bolivar2026' });

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('INVALID_CREDENTIALS');
  });
});

describe('GET /api/auth/me', () => {
  it('devuelve el perfil del usuario autenticado', async () => {
    const registerResponse = await api.post('/api/auth/register').send(validUser);
    const response = await api
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${registerResponse.body.token}`);

    expect(response.status).toBe(200);
    expect(response.body.user.email).toBe(validUser.email);
  });

  it('rechaza una peticion sin token', async () => {
    const response = await api.get('/api/auth/me');

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('UNAUTHORIZED');
  });

  it('rechaza un token expirado', async () => {
    const registerResponse = await api.post('/api/auth/register').send(validUser);
    const expiredToken = jwt.sign(
      { sub: registerResponse.body.user.id, email: validUser.email },
      process.env.JWT_SECRET,
      { algorithm: 'HS256', expiresIn: '-1s' },
    );

    const response = await api
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${expiredToken}`);

    expect(response.status).toBe(401);
    expect(response.body.error.code).toBe('TOKEN_EXPIRED');
  });
});
