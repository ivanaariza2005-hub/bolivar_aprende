import { Router } from 'express';
import authRoutes from './auth.routes.js';
import offerRoutes from './offer.routes.js';

const router = Router();

router.use('/auth', authRoutes);
router.use('/offers', offerRoutes);

export default router;
