import mongoose from "mongoose";
import Order from "../../models/shop/Order.model.js";
import Cart from "../../models/shop/Cart.model.js";
import Address from "../../models/shop/address.js";
import Payment from "../../models/shop/Payment.model.js";

/**
 * =========================
 * PLACE ORDER
 * =========================
 */
export const placeOrder = async (req, res) => {
  try {
    const userId = req.userId;
    const { addressId, deliveryType, paymentMethod } = req.body; // deliveryType: "physical" | "digital"

    // 1️⃣ Validate delivery type
    if (!deliveryType || !["physical", "digital"].includes(deliveryType)) {
      return res.status(400).json({ message: "Invalid delivery type" });
    }

    // 2️⃣ If physical, validate address
    let address = null;
    if (deliveryType === "physical") {
      if (!addressId) return res.status(400).json({ message: "Address is required for physical delivery" });

      address = await Address.findOne({ _id: addressId, user: userId });
      if (!address) return res.status(400).json({ message: "Invalid address" });
    }

    // 3️⃣ Get cart
    const cart = await Cart.findOne({ user: userId }).populate("items.product");
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: "Cart is empty" });
    }

    // 4️⃣ Validate products
    for (const item of cart.items) {
      if (!item.product || !item.product.isActive) {
        return res.status(400).json({ message: "One or more products are unavailable" });
      }
    }

    const totalAmount = cart.items.reduce(
      (sum, item) => sum + item.product.price * item.quantity,
      0
    );

    // 5️⃣ Create payment (pending)
    const payment = await Payment.create({
      user: userId,
      amount: totalAmount,
      status: "pending",
      method: paymentMethod || "UPI",
    });

    // 6️⃣ Create order
    const order = await Order.create({
      user: userId,
      items: cart.items.map(i => ({
        product: i.product._id,
        quantity: i.quantity,
        price: i.product.price,
      })),
      totalAmount,
      status: "Placed",
      deliveryType,
      paymentId: payment._id,
      address: address?._id || null,
      astrologyReportLink: deliveryType === "digital" ? "https://example.com/astrology-report" : undefined
    });

    // 7️⃣ Link payment to order
    payment.order = order._id;
    await payment.save();

    // 8️⃣ Clear cart
    await Cart.deleteOne({ _id: cart._id });

    return res.status(201).json({
      success: true,
      message: "Order placed successfully",
      order,
      payment
    });

  } catch (error) {
    console.error("PLACE ORDER ERROR:", error);
    return res.status(500).json({ message: "Order creation failed" });
  }
};

/**
 * =========================
 * GET USER ORDERS
 * =========================
 */
export const getUserOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.userId })
      .populate("items.product", "name price images")
      .populate("address")
      .populate("paymentId")
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      count: orders.length,
      orders
    });
  } catch (error) {
    console.error("GET ORDERS ERROR:", error);
    return res.status(500).json({ message: "Failed to fetch orders" });
  }
};

/**
 * =========================
 * GET ORDER BY ID
 * =========================
 */
export const getOrderById = async (req, res) => {
  try {
    let { orderId } = req.params;
    if (!orderId) return res.status(400).json({ message: "Order ID is required" });

    orderId = decodeURIComponent(orderId).trim();
    if (!mongoose.Types.ObjectId.isValid(orderId)) {
      return res.status(400).json({ message: "Invalid order ID" });
    }

    const order = await Order.findById(orderId)
      .populate("items.product", "name price images")
      .populate("address")
      .populate("paymentId");

    if (!order || order.user.toString() !== req.userId) {
      return res.status(404).json({ message: "Order not found" });
    }

    return res.json({ success: true, order });
  } catch (error) {
    console.error("GET ORDER ERROR:", error);
    return res.status(500).json({ message: "Failed to fetch order" });
  }
};

/**
 * =========================
 * ADMIN: GET ALL ORDERS
 * =========================
 */
export const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate("items.product", "name price images")
      .populate("address")
      .populate("user", "fullName email")
      .populate("paymentId")
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      count: orders.length,
      orders
    });
  } catch (error) {
    console.error("GET ALL ORDERS ERROR:", error);
    return res.status(500).json({ message: "Failed to fetch orders" });
  }
};
