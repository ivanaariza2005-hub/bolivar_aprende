import { prisma } from '../lib/prisma.js';

export const exists = async (userId, offerId) => {
  const row = await prisma.savedOffer.findUnique({
    where: { userId_offerId: { userId, offerId } },
    select: { userId: true },
  });
  return row !== null;
};

export const save = (userId, offerId) =>
  prisma.savedOffer.upsert({
    where: { userId_offerId: { userId, offerId } },
    create: { userId, offerId },
    update: {},
  });

export const remove = (userId, offerId) =>
  prisma.savedOffer.deleteMany({ where: { userId, offerId } });
