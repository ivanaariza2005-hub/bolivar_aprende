import { Router } from 'express';
import {
  create,
  detail,
  list,
  remove,
  save,
  unsave,
  update,
} from '../controllers/offer.controller.js';
import { requireAuth } from '../middlewares/auth.middleware.js';
import { writeLimiter } from '../middlewares/rateLimit.middleware.js';
import { validate } from '../middlewares/validate.middleware.js';
import {
  listOffersQuerySchema,
  offerBodySchema,
  offerIdParamSchema,
} from '../validators/offer.validator.js';

const router = Router();

router.use(requireAuth);

router.get('/', validate(listOffersQuerySchema, 'query'), list);
router.get('/:id', validate(offerIdParamSchema, 'params'), detail);
router.post('/', writeLimiter, validate(offerBodySchema), create);
router.put(
  '/:id',
  writeLimiter,
  validate(offerIdParamSchema, 'params'),
  validate(offerBodySchema),
  update,
);
router.delete('/:id', writeLimiter, validate(offerIdParamSchema, 'params'), remove);
router.post('/:id/save', writeLimiter, validate(offerIdParamSchema, 'params'), save);
router.delete('/:id/save', writeLimiter, validate(offerIdParamSchema, 'params'), unsave);

export default router;
