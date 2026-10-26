import { notFoundError } from '../lib/errors.js';
import * as offerRepository from '../repositories/offer.repository.js';
import * as savedOfferRepository from '../repositories/savedOffer.repository.js';

const ensureOfferExists = async (offerId) => {
  const offerExists = await offerRepository.exists(offerId);

  if (!offerExists) {
    throw notFoundError('La oferta no existe o fue eliminada.');
  }
};

export const save = async (userId, offerId) => {
  await ensureOfferExists(offerId);
  await savedOfferRepository.save(userId, offerId);
  return { offerId, saved: true };
};

export const unsave = async (userId, offerId) => {
  await ensureOfferExists(offerId);
  await savedOfferRepository.remove(userId, offerId);
  return { offerId, saved: false };
};
