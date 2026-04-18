// models/Coupon.js
import mongoose from "mongoose";

const couponSchema = new mongoose.Schema({
  code: { type: String, required: true, unique: true },
  type: { type: String, enum: ["percentage", "fixed"], default: "percentage" },
  value: { type: Number, required: true }, // percentage or fixed amount
  minOrderAmount: { type: Number, default: 0 },
  expiry: { type: Date, required: true },
  usageLimit: { type: Number, default: 1 },
  usedCount: { type: Number, default: 0 },
  active: { type: Boolean, default: true }
}, { timestamps: true });

export default mongoose.model("Coupon", couponSchema);