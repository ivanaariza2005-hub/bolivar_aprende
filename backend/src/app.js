import cors from 'cors';
import express from 'express';
import helmet from 'helmet';
import pinoHttp from 'pino-http';
import { env } from './config/env.js';
import { logger } from './lib/logger.js';
import { errorHandler } from './middlewares/error.middleware.js';
import { notFoundHandler } from './middlewares/notFound.middleware.js';
import { globalLimiter } from './middlewares/rateLimit.middleware.js';
import router from './routes/index.js';

const allowedOrigins = env.corsOrigins.includes('*') ? true : env.corsOrigins;

export const createApp = () => {
  const app = express();

  // Detrás del proxy del PaaS (Render) el cliente real viene en X-Forwarded-For.
  // Sin esto, req.ip es la IP del balanceador y el rate limit se comparte entre
  // todos los usuarios.
  if (env.isProduction) {
    app.set('trust proxy', 1);
  }

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors({ origin: allowedOrigins }));
  app.use(express.json({ limit: '100kb' }));

  if (!env.isTest) {
    app.use(pinoHttp({ logger }));
  }

  app.use('/api', globalLimiter, router);
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};

export const app = createApp();
