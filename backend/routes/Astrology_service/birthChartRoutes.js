const express = require("express");
const router = express.Router();

const { generateBirthChart } = require("../../controllers/services/birthChartImage.js");
const { checkFeatureEnabled } = require("../../middlewares/checkFeature.js");
const { trackFeatureUsage } = require("../../middlewares/trackUsage.js");

// Generate Birth Chart
router.post(
  "/generate",
  checkFeatureEnabled("birth_chart"),
  trackFeatureUsage,
  generateBirthChart
);

module.exports = router;
