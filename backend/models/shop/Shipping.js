// models/Shipping.js
import mongoose from "mongoose";

const shippingSchema = new mongoose.Schema({
  name: { type: String, required: true }, // e.g., Standard, Express
  minDays: { type: Number, required: true },
  maxDays: { type: Number, required: true },
  cost: { type: Number, required: true },
  active: { type: Boolean, default: true }
}, { timestamps: true });

export default mongoose.model("Shipping", shippingSchema);