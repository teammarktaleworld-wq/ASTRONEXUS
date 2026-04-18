// controllers/users/category.controller.js
import Category from "../../models/shop/Category.model.js";

/**
 * GET ACTIVE CATEGORIES
 */
export const getActiveCategories = async (req, res) => {
  try {
    const categories = await Category.find({ isActive: true }).sort({ name: 1 });
    res.json(categories);
  } catch (err) {
    console.error("GET CATEGORIES ERROR:", err);
    res.status(500).json({ message: "Failed to fetch categories" });
  }
};
