import { prisma } from '../lib/prisma.js';

const savedByUser = (userId) => ({ where: { userId }, select: { userId: true } });

const buildWhere = ({ filters, userId }) => {
  const where = {};

  if (filters.type) {
    where.type = filters.type;
  }

  if (filters.municipality) {
    where.municipality = filters.municipality;
  }

  if (filters.savedOnly) {
    where.savedBy = { some: { userId } };
  }

  if (filters.q) {
    where.OR = [
      { title: { contains: filters.q } },
      { description: { contains: filters.q } },
      { institution: { contains: filters.q } },
    ];
  }

  return where;
};

export const findMany = ({ userId, filters }) =>
  prisma.offer.findMany({
    where: buildWhere({ filters, userId }),
    orderBy: { createdAt: 'desc' },
    include: { savedBy: savedByUser(userId) },
  });

export const findById = (id, userId) =>
  prisma.offer.findUnique({
    where: { id },
    include: { savedBy: savedByUser(userId) },
  });

export const create = (data, userId) =>
  prisma.offer.create({
    data,
    include: { savedBy: savedByUser(userId) },
  });

export const update = (id, data, userId) =>
  prisma.offer.update({
    where: { id },
    data,
    include: { savedBy: savedByUser(userId) },
  });

export const remove = (id) => prisma.offer.delete({ where: { id } });

export const exists = async (id) => {
  const offer = await prisma.offer.findUnique({ where: { id }, select: { id: true } });
  return offer !== null;
};

export const count = () => prisma.offer.count();
