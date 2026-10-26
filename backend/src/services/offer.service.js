import { notFoundError } from '../lib/errors.js';
import * as offerRepository from '../repositories/offer.repository.js';

export const toOfferDto = (offer) => ({
  id: offer.id,
  title: offer.title,
  description: offer.description,
  type: offer.type,
  institution: offer.institution,
  municipality: offer.municipality,
  modality: offer.modality,
  isSaved: Array.isArray(offer.savedBy) ? offer.savedBy.length > 0 : false,
  createdAt: offer.createdAt.toISOString(),
  updatedAt: offer.updatedAt.toISOString(),
});

export const list = async ({ userId, filters }) => {
  const offers = await offerRepository.findMany({ userId, filters });
  return offers.map(toOfferDto);
};

export const getById = async (id, userId) => {
  const offer = await offerRepository.findById(id, userId);

  if (!offer) {
    throw notFoundError('La oferta no existe o fue eliminada.');
  }

  return toOfferDto(offer);
};

export const create = async (payload, userId) => {
  const offer = await offerRepository.create(payload, userId);
  return toOfferDto(offer);
};

export const update = async (id, payload, userId) => {
  const existing = await offerRepository.findById(id, userId);

  if (!existing) {
    throw notFoundError('La oferta no existe o fue eliminada.');
  }

  const offer = await offerRepository.update(id, payload, userId);
  return toOfferDto(offer);
};

export const remove = async (id, userId) => {
  const existing = await offerRepository.findById(id, userId);

  if (!existing) {
    throw notFoundError('La oferta no existe o fue eliminada.');
  }

  await offerRepository.remove(id);
};
