import { asyncHandler } from '../lib/asyncHandler.js';
import * as offerService from '../services/offer.service.js';
import * as savedOfferService from '../services/savedOffer.service.js';

const parseFilters = (query) => ({
  q: query.q,
  type: query.type,
  municipality: query.municipality,
  savedOnly: query.saved === 'true',
});

export const list = asyncHandler(async (req, res) => {
  const offers = await offerService.list({
    userId: req.user.id,
    filters: parseFilters(req.query),
  });

  res.status(200).json({ data: offers, total: offers.length });
});

export const detail = asyncHandler(async (req, res) => {
  const offer = await offerService.getById(req.params.id, req.user.id);
  res.status(200).json({ data: offer });
});

export const create = asyncHandler(async (req, res) => {
  const offer = await offerService.create(req.body, req.user.id);
  res.status(201).json({ data: offer });
});

export const update = asyncHandler(async (req, res) => {
  const offer = await offerService.update(req.params.id, req.body, req.user.id);
  res.status(200).json({ data: offer });
});

export const remove = asyncHandler(async (req, res) => {
  await offerService.remove(req.params.id, req.user.id);
  res.status(204).send();
});

export const save = asyncHandler(async (req, res) => {
  const result = await savedOfferService.save(req.user.id, req.params.id);
  res.status(200).json({ data: result });
});

export const unsave = asyncHandler(async (req, res) => {
  const result = await savedOfferService.unsave(req.user.id, req.params.id);
  res.status(200).json({ data: result });
});
