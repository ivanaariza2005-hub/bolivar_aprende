import { Router } from 'express';
import authRoutes from './auth.routes.js';
import offerRoutes from './offer.routes.js';
import { prisma } from '../lib/prisma.js';
import { logger } from '../lib/logger.js';

const router = Router();

router.get('/health', async (_req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.status(200).json({ status: 'ok', database: 'connected' });
  } catch (error) {
    logger.error({ err: error }, 'Health check: base de datos no disponible');
    res.status(503).json({ status: 'error', database: 'disconnected' });
  }
});

router.use('/auth', authRoutes);
router.use('/offers', offerRoutes);

export default router;
