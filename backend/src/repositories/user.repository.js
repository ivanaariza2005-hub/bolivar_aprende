import { prisma } from '../lib/prisma.js';

const publicFields = {
  id: true,
  fullName: true,
  email: true,
  passwordHash: true,
  createdAt: true,
  updatedAt: true,
};

export const findByEmail = (email) =>
  prisma.user.findUnique({ where: { email }, select: publicFields });

export const findById = (id) =>
  prisma.user.findUnique({ where: { id }, select: publicFields });

export const create = ({ fullName, email, passwordHash }) =>
  prisma.user.create({
    data: { fullName, email, passwordHash },
    select: publicFields,
  });
