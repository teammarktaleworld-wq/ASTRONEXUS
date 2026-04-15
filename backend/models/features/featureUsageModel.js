const mongoose = require("mongoose");

const featureUsageSchema = new mongoose.Schema({
  featureKey: { type: String, required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  usedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("FeatureUsage", featureUsageSchema);
