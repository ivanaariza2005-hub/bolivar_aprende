import { AppError } from '../lib/errors.js';

export const validate = (schema, source = 'body') =>
  (req, res, next) => {
    const result = schema.safeParse(req[source]);

    if (result.success) {
      req[source] = result.data;
      next();
      return;
    }

    const details = result.error.issues.map((issue) => ({
      field: issue.path.join('.') || source,
      message: issue.message,
    }));

    next(new AppError('VALIDATION_ERROR', 400, 'Revisa los campos marcados.', details));
  };
