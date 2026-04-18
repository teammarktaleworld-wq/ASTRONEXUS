import express from "express";
import cors from "cors";
import horoscopeRoutes from "./routes/horoscope.routes.js";

const app = express();

app.use(cors());
app.use(express.json());

app.use("/api/horoscope", horoscopeRoutes);

app.get("/", (req, res) => {
  res.json({ status: "AstroNexus Horoscope API running" });
});

export default app;
