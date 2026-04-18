import express from "express";
import { getHoroscopeChartSvg } from "../../controllers/services/horoscopeController.js";

const router = express.Router();

// POST /api/horoscope/chart
router.post("/chart", getHoroscopeChartSvg);

export default router;
