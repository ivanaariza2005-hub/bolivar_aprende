import { AppError } from '../lib/errors.js';

export const notFoundHandler = (req, res, next) => {
  next(new AppError('ROUTE_NOT_FOUND', 404, 'La ruta solicitada no existe.'));
};
