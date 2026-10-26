import { AppError } from '../lib/errors.js';
import { comparePassword, hashPassword } from '../lib/password.js';
import { signToken } from '../lib/jwt.js';
import * as userRepository from '../repositories/user.repository.js';

const toUserDto = (user) => ({
  id: user.id,
  fullName: user.fullName,
  email: user.email,
  createdAt: user.createdAt.toISOString(),
});

const buildSession = (user) => ({
  token: signToken(user),
  user: toUserDto(user),
});

export const register = async ({ fullName, email, password }) => {
  const existing = await userRepository.findByEmail(email);

  if (existing) {
    throw new AppError('EMAIL_TAKEN', 409, 'Ya existe una cuenta con este correo electrónico.');
  }

  const passwordHash = await hashPassword(password);
  const user = await userRepository.create({ fullName, email, passwordHash });

  return buildSession(user);
};

export const login = async ({ email, password }) => {
  const user = await userRepository.findByEmail(email);

  if (!user) {
    throw new AppError('INVALID_CREDENTIALS', 401, 'El correo o la contraseña no son correctos.');
  }

  const isPasswordValid = await comparePassword(password, user.passwordHash);

  if (!isPasswordValid) {
    throw new AppError('INVALID_CREDENTIALS', 401, 'El correo o la contraseña no son correctos.');
  }

  return buildSession(user);
};

export const getProfile = async (userId) => {
  const user = await userRepository.findById(userId);

  if (!user) {
    throw new AppError('NOT_FOUND', 404, 'La cuenta no existe.');
  }

  return toUserDto(user);
};
