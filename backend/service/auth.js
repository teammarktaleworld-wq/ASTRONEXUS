// backend/service/auth.js
import jwt from "jsonwebtoken";

/**
 * Create a short-lived JWT access token
 */
export function createToken(user) {
  const payload = {
    id: user._id,
    email: user.email,
    name: user.name,
  };
  return jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || "7d", // e.g., 7d
  });
}

/**
 * Verify access token
 */
export function verifyToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    return null;
  }
}

/**
 * Create a long-lived refresh token
 */
export function createRefreshToken(user) {
  const payload = {
    id: user._id,
  };
  return jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || "30d", // e.g., 30d
  });
}

/**
 * Verify refresh token
 */
export function verifyRefreshToken(token) {
  try {
    return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
  } catch (error) {
    return null;
  }
}
