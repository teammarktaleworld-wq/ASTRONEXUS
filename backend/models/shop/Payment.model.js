import mongoose from "mongoose";

const paymentSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    order: { type: mongoose.Schema.Types.ObjectId, ref: "Order" },
    amount: { type: Number, required: true },
    method: {
      type: String,
      enum: ["UPI", "Card", "NetBanking", "Wallet","CASH"],
      default: "UPI",
    },
    status: {
      type: String,
      enum: ["pending", "success", "failed"],
      default: "pending",
    },
    transactionId: { type: String }, // From payment gateway
  },
  { timestamps: true }
);

export default mongoose.model("Payment", paymentSchema);
