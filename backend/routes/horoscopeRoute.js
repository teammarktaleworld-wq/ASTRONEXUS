import express from "express";
import { getDailyHoroscope } from "../controllers/services/dailyController.js";

const router = express.Router();

router.get("/daily", getDailyHoroscope);

export default router;
