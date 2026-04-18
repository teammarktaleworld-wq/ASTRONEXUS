import mongoose from "mongoose";

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true
    },

    description: {
      type: String,
      trim: true
    },

    price: {
      type: Number,
      required: true,
      min: 0
    },

    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      default: null
    },

    images: [
      {
        type: String,
        trim: true
      }
    ],

    astrologyType: {
      type: String,
      enum: ["gemstone", "pooja", "report", "consultation"],
      default: "gemstone"
    },

    stock: {
      type: Number,
      default: 0,
      min: 0
    },

    deliveryType: {
      type: String,
      enum: ["physical", "digital"],
      default: "physical"
    },

    isActive: {
      type: Boolean,
      default: true
    },

    isDeleted: {
      type: Boolean,
      default: false
    },

    // ---------------- HOME SCREEN RELATED ----------------
    showInHome: {
      type: Boolean,
      default: false, // Only products marked true will appear on home
    },

    lastShownAt: {
      type: Date,
      default: null, // Can be used to rotate suggestions
    },

    homePriority: {
      type: Number,
      default: 0, // Higher value = shows earlier in home
    }
  },
  {
    timestamps: true
  }
);

export default mongoose.model("Product", productSchema);