const express = require("express");
const router = express.Router();
const {
  getAstrologyDashboard,
  toggleFeature
} = require("../../controllers/services/adminAstroController.js");

router.get("/astro-dashboard", getAstrologyDashboard);
router.patch("/toggle-feature", toggleFeature);

module.exports = router;
