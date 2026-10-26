import rateLimit from 'express-rate-limit';
import { env } from '../config/env.js';

const commonOptions = {
  standardHeaders: true,
  legacyHeaders: false,
  skip: () => env.isTest,
  message: {
    error: {
      code: 'RATE_LIMITED',
      message: 'Demasiadas solicitudes. Espera unos minutos e intenta de nuevo.',
    },
  },
};

export const globalLimiter = rateLimit({
  ...commonOptions,
  windowMs: 15 * 60 * 1000,
  limit: 300,
});

export const authLimiter = rateLimit({
  ...commonOptions,
  windowMs: 15 * 60 * 1000,
  limit: 20,
});

export const writeLimiter = rateLimit({
  ...commonOptions,
  windowMs: 15 * 60 * 1000,
  limit: 120,
});
