// routes/notificationRoutes.js
import express from "express";
import { authenticateToken, authorizeAdmin } from "../../middlewares/auth.js";
import * as notificationController from "../../controllers/notification/notificationController.js";

const router = express.Router();

router.get("/", authenticateToken, notificationController.getNotifications);
router.put("/:notificationId/read", authenticateToken, notificationController.markAsRead);
router.post("/", authenticateToken, authorizeAdmin, notificationController.createNotification);

export default router;