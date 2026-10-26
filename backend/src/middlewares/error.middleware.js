import { Prisma } from '@prisma/client';
import { AppError } from '../lib/errors.js';
import { logger } from '../lib/logger.js';

const normalisePrismaError = (error) => {
  if (error instanceof Prisma.PrismaClientKnownRequestError) {
    if (error.code === 'P2002') {
      const target = Array.isArray(error.meta?.target) ? error.meta.target.join(',') : '';
      if (target.includes('email')) {
        return new AppError('EMAIL_TAKEN', 409, 'Ya existe una cuenta con este correo electrónico.');
      }
      return new AppError('CONFLICT', 409, 'La información enviada ya existe.');
    }

    if (error.code === 'P2025') {
      return new AppError('NOT_FOUND', 404, 'El recurso solicitado no existe.');
    }
  }

  return null;
};

export const errorHandler = (error, req, res, next) => {
  if (res.headersSent) {
    next(error);
    return;
  }

  if (error instanceof AppError) {
    res.status(error.status).json({
      error: {
        code: error.code,
        message: error.message,
        ...(error.details ? { details: error.details } : {}),
      },
    });
    return;
  }

  const prismaError = normalisePrismaError(error);

  if (prismaError) {
    res.status(prismaError.status).json({
      error: { code: prismaError.code, message: prismaError.message },
    });
    return;
  }

  if (error instanceof SyntaxError && 'body' in error) {
    res.status(400).json({
      error: { code: 'INVALID_JSON', message: 'El cuerpo de la solicitud no es un JSON válido.' },
    });
    return;
  }

  logger.error({ err: error, path: req.originalUrl, method: req.method }, 'Error no controlado');

  res.status(500).json({
    error: {
      code: 'INTERNAL_ERROR',
      message: 'Ocurrió un error inesperado. Intenta de nuevo.',
    },
  });
};
