import { z } from 'zod';
import { MUNICIPALITIES } from '../constants/municipalities.js';
import { OFFER_MODALITIES, OFFER_TYPES } from '../constants/offerEnums.js';

export const offerBodySchema = z.object({
  title: z
    .string({ required_error: 'Ingresa el título de la oferta.' })
    .trim()
    .min(5, 'El título debe tener al menos 5 caracteres.')
    .max(120, 'El título no puede superar 120 caracteres.'),
  description: z
    .string({ required_error: 'Ingresa la descripción de la oferta.' })
    .trim()
    .min(20, 'La descripción debe tener al menos 20 caracteres.')
    .max(2000, 'La descripción no puede superar 2000 caracteres.'),
  type: z.enum(OFFER_TYPES, {
    errorMap: () => ({ message: 'Selecciona un tipo de oferta válido.' }),
  }),
  institution: z
    .string({ required_error: 'Ingresa la institución que publica la oferta.' })
    .trim()
    .min(2, 'La institución debe tener al menos 2 caracteres.')
    .max(120, 'La institución no puede superar 120 caracteres.'),
  municipality: z.enum(MUNICIPALITIES, {
    errorMap: () => ({ message: 'Selecciona un municipio de Bolívar.' }),
  }),
  modality: z.enum(OFFER_MODALITIES, {
    errorMap: () => ({ message: 'Selecciona una modalidad válida.' }),
  }),
});

export const offerIdParamSchema = z.object({
  id: z.string().uuid('El identificador de la oferta no es válido.'),
});

export const listOffersQuerySchema = z.object({
  q: z.string().trim().max(100, 'La búsqueda no puede superar 100 caracteres.').optional(),
  type: z
    .enum(OFFER_TYPES, {
      errorMap: () => ({ message: 'El tipo de oferta no es válido.' }),
    })
    .optional(),
  municipality: z
    .enum(MUNICIPALITIES, {
      errorMap: () => ({ message: 'El municipio no pertenece a Bolívar.' }),
    })
    .optional(),
  saved: z
    .enum(['true', 'false'], {
      errorMap: () => ({ message: 'El filtro de guardadas debe ser true o false.' }),
    })
    .optional(),
});
