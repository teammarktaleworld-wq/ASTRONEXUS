// routes/discountRoutes.js
import express from "express";
import * as discountController from "../../controllers/discountController.js";
import { authenticateToken, authorizeAdmin } from "../../middlewares/auth.js";

const router = express.Router();

// Only admins can create/update/delete discounts
router.post("/", authenticateToken, authorizeAdmin, discountController.createDiscount);
router.get("/", discountController.getDiscounts);
router.get("/:code", discountController.getDiscountByCode);
router.put("/:discountId", authenticateToken, authorizeAdmin, discountController.updateDiscount);
router.delete("/:discountId", authenticateToken, authorizeAdmin, discountController.deleteDiscount);

router.post("/apply", discountController.applyDiscount);

export default router;