// controllers/users/couponController.js
import Coupon from "../../models/shop/Coupon.js";

// Create coupon (Admin)
export const createCoupon = async (req, res) => {
  const { code, type, value, minOrderAmount, expiry, usageLimit } = req.body;
  try {
    const coupon = new Coupon({ code, type, value, minOrderAmount, expiry, usageLimit });
    await coupon.save();
    res.status(201).json(coupon);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Apply coupon
export const applyCoupon = async (req, res) => {
  const { code, amount } = req.body; // amount = cart/order total
  try {
    const coupon = await Coupon.findOne({ code, active: true });
    if (!coupon) return res.status(404).json({ error: "Coupon not found" });
    if (coupon.expiry < new Date()) return res.status(400).json({ error: "Coupon expired" });
    if (coupon.usedCount >= coupon.usageLimit) return res.status(400).json({ error: "Coupon usage limit reached" });
    if (amount < coupon.minOrderAmount) return res.status(400).json({ error: `Minimum order amount ${coupon.minOrderAmount}` });

    // Calculate discounted amount
    let discountAmount = coupon.type === "percentage" ? (amount * coupon.value) / 100 : coupon.value;
    const finalAmount = amount - discountAmount;

    res.json({ originalAmount: amount, discountAmount, finalAmount, code });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Increment used count after successful order
export const incrementCouponUsage = async (couponId) => {
  await Coupon.findByIdAndUpdate(couponId, { $inc: { usedCount: 1 } });
};