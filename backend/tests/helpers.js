import { prisma } from '../src/lib/prisma.js';

export const resetDatabase = async () => {
  await prisma.savedOffer.deleteMany();
  await prisma.offer.deleteMany();
  await prisma.user.deleteMany();
};

export const disconnectDatabase = () => prisma.$disconnect();

export const sampleOffer = (overrides = {}) => ({
  title: 'Aprendiz de operaciones portuarias',
  description:
    'Programa de formacion de seis meses con contrato de aprendizaje en la zona industrial de Mamonal.',
  type: 'job',
  institution: 'Logistica Portuaria del Caribe',
  municipality: 'Cartagena',
  modality: 'onsite',
  ...overrides,
});
