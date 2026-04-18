import { verifyToken } from "../service/auth.js";
import mongoose from "mongoose";
import User from "../models/user/user.js"; // adjust path if needed


// ✅ Admin authorization middleware
export const authorizeAdmin = (req, res, next) => {
  if (!req.user || req.user.role !== "admin") {
    return res.status(403).json({ message: "Admin access required" });
  }
  next();
};


/**
 * Middleware: Authenticate API token (for Flutter / mobile / API requests)
 */

export function authenticateToken(req, res, next) {
  try {
    // Get token from Authorization header or cookies
    const token = req.cookies?.token || req.headers.authorization?.split(" ")[1];

    if (!token) {
      return res.status(401).json({ error: "Access denied. No token provided." });
    }

    const decoded = verifyToken(token);

    if (!decoded) {
      return res.status(401).json({ error: "Invalid or expired token." });
    }

    // Use `id` if available, else fallback to email
    req.userId = decoded.id || decoded._id;
    req.user = decoded;

    next();
  } catch (err) {
    console.error("Token error:", err);
    return res.status(401).json({ error: "Invalid token." });
  }
}

/**
 * Middleware: Authenticate token for web routes (cookie-based)
 */
export function authenticateTokenForWeb(req, res, next) {
  try {
    const token = req.cookies?.token;

    if (!token) return res.redirect("/login");

    const decoded = verifyToken(token);

    if (!decoded) return res.redirect("/login");

    req.userId = decoded.id || decoded.email;
    req.user = decoded;

    next();
  } catch (err) {
    console.error("Web token error:", err);
    return res.redirect("/login");
  }
}

/**
 * Middleware: Optional authentication
 * If a token exists, attaches user info; otherwise proceeds without error
 */
export function optionalAuth(req, res, next) {
  try {
    const token = req.cookies?.token || req.headers.authorization?.split(" ")[1];

    if (token) {
      const decoded = verifyToken(token);
      if (decoded) {
        req.userId = decoded.id || decoded.email;
        req.user = decoded;
      }
    }

    next();
  } catch (err) {
    console.error("Optional auth error:", err);
    next();
  }
}
