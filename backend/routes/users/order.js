// routes/users/order.js
import express from "express";
import { placeOrder, getUserOrders } from "../../controllers/users/orderController.js";
import { authenticateToken } from "../../middlewares/auth.js";

const router = express.Router();

// All routes require user to be logged in
router.use(authenticateToken);

router.post("/", placeOrder);
router.get("/", getUserOrders);

export default router; // ✅ default export for ES Modules
