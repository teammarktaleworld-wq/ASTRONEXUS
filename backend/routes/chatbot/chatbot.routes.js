import express from "express";
import { askAstrologyChatbot } from "../../controllers/chat/chatbot.controller.js";
import { authenticateToken } from "../../middlewares/auth.js";
import { checkFeatureEnabled } from "../../middlewares/checkFeature.js";
import { trackFeatureUsage } from "../../middlewares/trackUsage.js";

const router = express.Router();

// Ask Astrology Chatbot
router.post(
  "/ask",
  authenticateToken,                     // 👈 user must be logged in
  checkFeatureEnabled("astrology_chat"), // 👈 feature flag
  trackFeatureUsage,                     // 👈 usage tracking
  askAstrologyChatbot
);

export default router;
