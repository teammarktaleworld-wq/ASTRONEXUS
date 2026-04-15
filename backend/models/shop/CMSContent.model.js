const mongoose = require("mongoose");

const CMSContentSchema = new mongoose.Schema({
  type: {
    type: String,
    enum: ["banner", "horoscope", "blog", "announcement"],
    required: true
  },

  title: String,

  content: String,

  image: String,

  isActive: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model("CMSContent", CMSContentSchema);
