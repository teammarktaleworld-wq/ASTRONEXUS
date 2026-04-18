const express = require("express");
const router = express.Router();

const {
  ashtakootScore
} = require("../../controllers/services/compatabiltycontroller.js");

const { checkFeatureEnabled } = require("../../middlewares/checkFeature.js");
const { trackFeatureUsage } = require("../../middlewares/trackUsage.js");

// Generate Ashtakoot Compatibility Score
router.post(
  "/match-making/ashtakoot-score",
  checkFeatureEnabled("compatibility"),   // 👈 feature key
  trackFeatureUsage,                      // 👈 usage tracking
  ashtakootScore
);

module.exports = router;
