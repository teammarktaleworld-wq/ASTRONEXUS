import express from "express";
import { authenticateToken, authorizeAdmin } from "../../middlewares/auth.js";
import * as couponController from "../../controllers/users/couponController.js";

const router = express.Router();

router.post("/", authenticateToken, authorizeAdmin, couponController.createCoupon);
router.post("/apply", authenticateToken, couponController.applyCoupon);

export default router;