const mongoose = require("mongoose");

const featureFlagSchema = new mongoose.Schema({
  key: { type: String, required: true, unique: true }, // e.g. "birth_chart"
  name: String, // Display name
  enabled: { type: Boolean, default: true },
  isPremium: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model("FeatureFlag", featureFlagSchema);
