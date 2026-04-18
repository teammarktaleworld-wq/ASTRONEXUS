import Order from "../../models/shop/Order.model.js";

/**
 * GET ALL ORDERS
 */
export const getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate({ path: "items.product", select: "name price images" })
      .populate({ path: "user", select: "name email" })
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: orders.length,
      orders
    });
  } catch (err) {
    console.error("GET ALL ORDERS ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

/**
 * UPDATE ORDER STATUS
 */
export const updateStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!id || !status) {
      return res.status(400).json({ message: "ID and status required" });
    }

    const updatedOrder = await Order.findByIdAndUpdate(
      id,
      { status },
      { new: true }
    ).populate("items.product", "name price images");

    if (!updatedOrder) {
      return res.status(404).json({ message: "Order not found" });
    }

    res.json({ success: true, order: updatedOrder });
  } catch (err) {
    console.error("UPDATE ORDER STATUS ERROR:", err);
    res.status(500).json({ message: "Failed to update order status" });
  }
};

/**
 * DELETE ORDER
 */
export const deleteOrder = async (req, res) => {
  try {
    const { id } = req.params;

    const deleted = await Order.findByIdAndDelete(id);

    if (!deleted) {
      return res.status(404).json({ message: "Order not found" });
    }

    res.json({
      success: true,
      message: "Order deleted successfully",
      orderId: id
    });
  } catch (err) {
    console.error("DELETE ORDER ERROR:", err);
    res.status(500).json({ message: "Failed to delete order" });
  }
};

/**
 * ORDER COUNTS
 */
export const getOrderCounts = async (req, res) => {
  try {
    const total = await Order.countDocuments();
    const completed = await Order.countDocuments({ status: "Completed" });
    const pending = await Order.countDocuments({ status: "Placed" });
    const cancelled = await Order.countDocuments({ status: "Cancelled" });

    res.json({
      success: true,
      total,
      completed,
      pending,
      cancelled
    });
  } catch (err) {
    console.error("ORDER COUNT ERROR:", err);
    res.status(500).json({ message: "Failed to get order counts" });
  }
};

/**
 * ORDERS BY USER
 */
export const getOrdersByUser = async (req, res) => {
  try {
    const { userId } = req.params;

    const orders = await Order.find({ user: userId })
      .populate("items.product", "name price images")
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: orders.length,
      orders
    });
  } catch (err) {
    console.error("GET USER ORDERS ERROR:", err);
    res.status(500).json({ message: "Failed to get user orders" });
  }
};
