import jwt from 'jsonwebtoken';
import { env } from '../config/env.js';
import { AppError } from './errors.js';

export const signToken = (user) =>
  jwt.sign({ sub: user.id, email: user.email }, env.JWT_SECRET, {
    algorithm: 'HS256',
    expiresIn: env.JWT_EXPIRES_IN,
  });

export const verifyToken = (token) => {
  try {
    return jwt.verify(token, env.JWT_SECRET, { algorithms: ['HS256'] });
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      throw new AppError('TOKEN_EXPIRED', 401, 'Tu sesión expiró. Inicia sesión de nuevo.');
    }
    throw new AppError('UNAUTHORIZED', 401, 'Tu sesión no es válida. Inicia sesión de nuevo.');
  }
};
