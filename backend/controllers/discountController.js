import Discount from "../models/shop/Discount.js";

// ================= CREATE =================
export const createDiscount = async (req, res) => {
  try {
    const { code, percentage, expiry } = req.body;

    if (!code || !percentage || !expiry) {
      return res.status(400).json({ error: "All fields are required" });
    }

    if (percentage <= 0 || percentage > 100) {
      return res.status(400).json({ error: "Invalid percentage" });
    }

    if (new Date(expiry) <= new Date()) {
      return res.status(400).json({ error: "Expiry must be in the future" });
    }

    const discount = await Discount.create({
      code: code.toUpperCase(),
      percentage,
      expiry,
    });

    res.status(201).json(discount);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ================= GET ALL =================
export const getDiscounts = async (req, res) => {
  try {
    const discounts = await Discount.find({
      active: true,
      expiry: { $gt: new Date() },
    }).sort({ createdAt: -1 });

    res.json(discounts);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ================= GET BY CODE =================
export const getDiscountByCode = async (req, res) => {
  try {
    const discount = await Discount.findOne({
      code: req.params.code.toUpperCase(),
      active: true,
      expiry: { $gt: new Date() },
    });

    if (!discount) {
      return res.status(404).json({ error: "Discount not found or expired" });
    }

    res.json(discount);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ================= UPDATE =================
export const updateDiscount = async (req, res) => {
  try {
    const discount = await Discount.findByIdAndUpdate(
      req.params.discountId,
      req.body,
      { new: true, runValidators: true }
    );

    if (!discount) {
      return res.status(404).json({ error: "Discount not found" });
    }

    res.json(discount);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ================= SOFT DELETE =================
export const deleteDiscount = async (req, res) => {
  try {
    const discount = await Discount.findByIdAndUpdate(
      req.params.discountId,
      { active: false },
      { new: true }
    );

    if (!discount) {
      return res.status(404).json({ error: "Discount not found" });
    }

    res.json({ message: "Discount deactivated" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// ================= APPLY =================
export const applyDiscount = async (req, res) => {
  try {
    const { code, amount } = req.body;

    const discount = await Discount.findOne({
      code: code.toUpperCase(),
      active: true,
      expiry: { $gt: new Date() },
    });

    if (!discount) {
      return res.status(404).json({ error: "Invalid or expired discount" });
    }

    const discountAmount = (amount * discount.percentage) / 100;
    const finalAmount = Math.max(amount - discountAmount, 0);

    res.json({
      originalAmount: amount,
      discountAmount,
      finalAmount,
      code: discount.code,
      percentage: discount.percentage,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};