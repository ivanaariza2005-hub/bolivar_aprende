import { Router } from 'express';
import authRoutes from './auth.routes.js';
import offerRoutes from './offer.routes.js';
import { prisma } from '../lib/prisma.js';

const router = Router();

router.get('/health', async (_req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.status(200).json({ status: 'ok', database: 'connected' });
  } catch (error) {
    res.status(503).json({ status: 'error', database: 'disconnected', details: error.message });
  }
});

router.use('/auth', authRoutes);
router.use('/offers', offerRoutes);

export default router;
