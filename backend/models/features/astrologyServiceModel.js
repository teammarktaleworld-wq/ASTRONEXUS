const mongoose = require("mongoose");

const astrologyServiceSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    key: { type: String, required: true, unique: true },
    description: { type: String },
    enabled: { type: Boolean, default: true },
    isPremium: { type: Boolean, default: false }
  },
  { timestamps: true }
);

module.exports = mongoose.model("AstrologyService", astrologyServiceSchema);