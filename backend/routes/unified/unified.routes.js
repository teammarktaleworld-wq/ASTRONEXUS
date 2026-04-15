import express from "express";
import {
  aggregateUnified,
  proxyBirthChart,
  proxyHoroscope,
  proxyMatiChat,
  unifiedHealth,
} from "../../controllers/unified/unifiedController.js";

const router = express.Router();

router.get("/health", unifiedHealth);
router.post("/birth-chart", proxyBirthChart);
router.get("/horoscope", proxyHoroscope);
router.post("/mati-chat", proxyMatiChat);
router.post("/aggregate", aggregateUnified);

export default router;
