import { asyncHandler } from '../lib/asyncHandler.js';
import * as authService from '../services/auth.service.js';

export const register = asyncHandler(async (req, res) => {
  const session = await authService.register(req.body);
  res.status(201).json(session);
});

export const login = asyncHandler(async (req, res) => {
  const session = await authService.login(req.body);
  res.status(200).json(session);
});

export const me = asyncHandler(async (req, res) => {
  const user = await authService.getProfile(req.user.id);
  res.status(200).json({ user });
});
