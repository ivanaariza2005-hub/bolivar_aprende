export class AppError extends Error {
  constructor(code, status, message, details = null) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.status = status;
    this.details = details;
    this.isOperational = true;
  }
}

export const notFoundError = (message = 'El recurso solicitado no existe.') =>
  new AppError('NOT_FOUND', 404, message);

export const unauthorizedError = (message = 'Debes iniciar sesión para continuar.') =>
  new AppError('UNAUTHORIZED', 401, message);
