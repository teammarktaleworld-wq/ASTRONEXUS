import express from "express";
import {
  createCategory,
  getAllCategories,
  updateCategory,
  toggleCategoryStatus,
  deleteCategory
} from "../../controllers/admin/admin.category.controller.js";

const router = express.Router();

router.post("/", createCategory);
router.get("/", getAllCategories);
router.put("/:id", updateCategory);
router.patch("/:id/toggle", toggleCategoryStatus);
router.delete("/:id", deleteCategory);


export default router;
