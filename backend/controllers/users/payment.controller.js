import Payment from "../../models/shop/Payment.model.js";

/**
 * CREATE PAYMENT
 */
export const createPayment = async (req, res) => {
  try {
    const { amount, method } = req.body;

    const payment = await Payment.create({
      user: req.userId,
      amount,
      status: "pending",
      method: method || "UPI",
    });

    res.status(201).json({ success: true, payment });
  } catch (error) {
    console.error("CREATE PAYMENT ERROR:", error);
    res.status(500).json({ message: "Failed to create payment" });
  }
};

/**
 * VERIFY PAYMENT
 */
export const verifyPayment = async (req, res) => {
  try {
    const { paymentId, transactionId } = req.body;

    const payment = await Payment.findById(paymentId);

    if (!payment) return res.status(404).json({ message: "Payment not found" });

    payment.status = "success";
    if (transactionId) payment.transactionId = transactionId;

    await payment.save();

    res.json({ success: true, payment });
  } catch (error) {
    console.error("VERIFY PAYMENT ERROR:", error);
    res.status(500).json({ message: "Failed to verify payment" });
  }
};
