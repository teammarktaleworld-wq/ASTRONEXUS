import { Router } from "express";
import {
  getAllOrders,
  updateStatus,
  deleteOrder,
  getOrderCounts,
  getOrdersByUser
} from "../../controllers/admin/admin.order.controller.js";

import { authenticateToken } from "../../middlewares/auth.js";
import admin from "../../middlewares/admin.middleware.js";

const router = Router();

router.use(authenticateToken, admin);

router.get("/all", getAllOrders);
router.put("/:id/status", updateStatus);
router.delete("/:id", deleteOrder);
router.get("/counts", getOrderCounts);
router.get("/user/:userId", getOrdersByUser);

export default router;
