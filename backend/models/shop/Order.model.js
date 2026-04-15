import mongoose from "mongoose";

const orderItemSchema = new mongoose.Schema(
  {
    product: { type: mongoose.Schema.Types.ObjectId, ref: "Product", required: true },
    quantity: { type: Number, required: true, min: 1 },
    price: { type: Number, required: true },
  },
  { _id: false }
);

const orderSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    items: [orderItemSchema],
    totalAmount: { type: Number, required: true },
    status: {
      type: String,
      enum: ["Placed", "Processing", "Shipped", "Delivered", "Completed", "Cancelled"],
      default: "Placed",
    },
    deliveryType: {
      type: String,
      enum: ["physical", "digital"],
      default: "physical",
    },
    paymentId: { type: mongoose.Schema.Types.ObjectId, ref: "Payment" },
    astrologyReportLink: { type: String }, // For digital/astrology products
    address: { type: mongoose.Schema.Types.ObjectId, ref: "Address", required: function() {
      return this.deliveryType === "physical";
    } },
  },
  { timestamps: true }
);

export default mongoose.model("Order", orderSchema);
