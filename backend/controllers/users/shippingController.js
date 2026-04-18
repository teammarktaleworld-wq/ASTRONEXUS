// controllers/users/shippingController.js
import Shipping from "../../models/shop/Shipping.js";

// Get all active shipping methods
export const getShippingMethods = async (req, res) => {
  try {
    const methods = await Shipping.find({ active: true });
    res.json(methods);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Admin create shipping method
export const createShippingMethod = async (req, res) => {
  const { name, minDays, maxDays, cost } = req.body;
  try {
    const shipping = new Shipping({ name, minDays, maxDays, cost });
    await shipping.save();
    res.status(201).json(shipping);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Update shipping method
export const updateShippingMethod = async (req, res) => {
  const { shippingId } = req.params;
  try {
    const shipping = await Shipping.findByIdAndUpdate(shippingId, req.body, { new: true });
    res.json(shipping);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};

// Deactivate shipping method
export const deleteShippingMethod = async (req, res) => {
  const { shippingId } = req.params;
  try {
    const shipping = await Shipping.findByIdAndUpdate(shippingId, { active: false }, { new: true });
    res.json({ message: "Shipping method deactivated", shipping });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
};