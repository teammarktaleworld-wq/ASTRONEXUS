import mongoose from "mongoose";

const feedbackSchema = new mongoose.Schema(
  {
    productId: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: "Product", 
      required: true 
    },

    userId: { 
      type: mongoose.Schema.Types.ObjectId, 
      ref: "User", 
      required: true 
    },

    userName: { 
      type: String, 
      required: true 
    },

    userDisplay: { 
      type: String 
    },

    // ⭐ Rating Field (1–5)
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },

    // Optional review text
    description: { 
      type: String,
      trim: true,
      maxlength: 1000,
    },

  },
  { timestamps: true }
);

// ❗ One review per user per product
feedbackSchema.index({ productId: 1, userId: 1 }, { unique: true });

export default mongoose.model("Feedback", feedbackSchema);
