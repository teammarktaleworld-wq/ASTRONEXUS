// controllers/admin/category.controller.js
import Category from "../../models/shop/Category.model.js";

/**
 * CREATE CATEGORY
 * POST /api/admin/categories
 */
export const createCategory = async (req, res) => {
  try {
    const { name } = req.body;
    if (!name) return res.status(400).json({ message: "Category name is required" });

    const exists = await Category.findOne({ name });
    if (exists) return res.status(409).json({ message: "Category already exists" });

    const category = await Category.create({ name });
    res.status(201).json(category);
  } catch (err) {
    console.error("CREATE CATEGORY ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

/**
 * GET ALL CATEGORIES
 * GET /api/admin/categories
 */
export const getAllCategories = async (req, res) => {
  try {
    const categories = await Category.find().sort({ createdAt: -1 });
    res.json(categories);
  } catch (err) {
    console.error("GET CATEGORIES ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

/**
 * UPDATE CATEGORY
 * PUT /api/admin/categories/:id
 */
export const updateCategory = async (req, res) => {
  try {
    const updated = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updated) return res.status(404).json({ message: "Category not found" });

    res.json(updated);
  } catch (err) {
    console.error("UPDATE CATEGORY ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

/**
 * TOGGLE CATEGORY STATUS
 * PATCH /api/admin/categories/:id/toggle
 */

export const toggleCategoryStatus = async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) return res.status(404).json({ message: "Category not found" });

    category.isActive = !category.isActive;
    await category.save();

    res.json(category);
  } catch (err) {
    console.error("TOGGLE CATEGORY STATUS ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

export const deleteCategory = async (req, res) => {
  try {
    const deleted = await Category.findByIdAndDelete(req.params.id);

    if (!deleted) {
      return res.status(404).json({ message: "Category not found" });
    }

    res.json({ message: "Category deleted successfully" });
  } catch (err) {
    console.error("DELETE CATEGORY ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

