import { z } from 'zod';

const emailField = z
  .string({ required_error: 'Ingresa tu correo electrónico.' })
  .trim()
  .toLowerCase()
  .min(1, 'Ingresa tu correo electrónico.')
  .max(120, 'El correo no puede superar 120 caracteres.')
  .email('Ingresa un correo electrónico válido.');

const passwordField = z
  .string({ required_error: 'Ingresa una contraseña.' })
  .min(8, 'La contraseña debe tener al menos 8 caracteres.')
  .max(64, 'La contraseña no puede superar 64 caracteres.')
  .regex(/[A-Za-z]/, 'La contraseña debe incluir al menos una letra.')
  .regex(/[0-9]/, 'La contraseña debe incluir al menos un número.');

export const registerSchema = z
  .object({
    fullName: z
      .string({ required_error: 'Ingresa tu nombre completo.' })
      .trim()
      .min(3, 'El nombre debe tener al menos 3 caracteres.')
      .max(80, 'El nombre no puede superar 80 caracteres.'),
    email: emailField,
    password: passwordField,
    passwordConfirmation: z
      .string({ required_error: 'Confirma tu contraseña.' })
      .min(1, 'Confirma tu contraseña.'),
  })
  .refine((data) => data.password === data.passwordConfirmation, {
    path: ['passwordConfirmation'],
    message: 'Las contraseñas no coinciden.',
  });

export const loginSchema = z.object({
  email: emailField,
  password: z
    .string({ required_error: 'Ingresa tu contraseña.' })
    .min(1, 'Ingresa tu contraseña.')
    .max(64, 'La contraseña no puede superar 64 caracteres.'),
});
