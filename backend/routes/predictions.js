import express from "express";
import { getGeneralPrediction } from "../controllers/services/predictionController.js";

const router = express.Router();

router.get("/test", (req, res) => {
  res.send("Prediction route working!");
});


router.post("/generate", getGeneralPrediction);

export default router;
