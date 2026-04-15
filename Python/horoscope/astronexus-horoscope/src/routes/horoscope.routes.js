import express from "express";
import { getHoroscope } from "../controllers/horoscope.controller.js";

const router = express.Router();

router.get("/", getHoroscope);

export default router;
