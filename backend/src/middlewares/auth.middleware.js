import { AppError, unauthorizedError } from '../lib/errors.js';
import { verifyToken } from '../lib/jwt.js';
import * as userRepository from '../repositories/user.repository.js';

export const requireAuth = async (req, res, next) => {
  try {
    const header = req.headers.authorization ?? '';

    if (!header.startsWith('Bearer ')) {
      throw unauthorizedError();
    }

    const token = header.slice('Bearer '.length).trim();

    if (token.length === 0) {
      throw unauthorizedError();
    }

    const payload = verifyToken(token);
    const user = await userRepository.findById(payload.sub);

    if (!user) {
      throw unauthorizedError('La cuenta asociada a la sesión no existe.');
    }

    req.user = { id: user.id, fullName: user.fullName, email: user.email };
    next();
  } catch (error) {
    if (error instanceof AppError) {
      next(error);
      return;
    }
    next(unauthorizedError());
  }
};
