const express = require("express");
const router = express.Router();

const { getRandomCards } = require("../../controllers/services/tarotController.js");
const { checkFeatureEnabled } = require("../../middlewares/checkFeature.js");
const { trackFeatureUsage } = require("../../middlewares/trackUsage.js");
const { authenticateToken } = require("../../middlewares/auth.js");

// GET /api/tarot/random?n=3
router.get(
  "/random",
  authenticateToken,               // 👈 user must be logged in (optional if you want public)
  checkFeatureEnabled("tarot"),     // 👈 feature flag
  trackFeatureUsage,               // 👈 usage tracking
  getRandomCards
);

module.exports = router;
