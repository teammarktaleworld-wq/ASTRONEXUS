import dotenv from "dotenv";
dotenv.config();

import express from "express";
import path from "path";
import cookieParser from "cookie-parser";
import cors from "cors";
import morgan from "morgan";
import { fileURLToPath } from "url";

import { connectToMongoDB } from "./connect.js";
import { authenticateToken, optionalAuth } from "./middlewares/auth.js";
import URL from "./models/url.js";
import tarotRoutes from './routes/Astrology_service/tarotRoutes.js';

// ================= EXISTING ROUTES =================
import predictionsRoute from "./routes/predictions.js";
import birthChartRoute from "./routes/Astrology_service/birthChartRoutes.js";
import urlRoute from "./routes/url.js";
import staticRoute from "./routes/staticRouter.js";
import userRoute from "./routes/users/user.js";
import compatibilityRoute from "./routes/Astrology_service/compatablity.js";
import horoscopeRoute from "./routes/Astrology_service/horoscope.js";

// ================= ADMIN ROUTES =================
import adminAuthRoutes from "./routes/admin/admin.auth.routes.js";
import adminProductRoutes from "./routes/admin/admin.product.routes.js";
import adminOrderRoutes from "./routes/admin/admin.order.routes.js";
import adminCMSRoutes from "./routes/admin/admin.cms.routes.js";
import adminDashboardRoutes from "./routes/admin/admin.dashboard.routes.js";
import adminCategoryRoutes from "./routes/admin/categories.js";
import adminUserRoutes from "./routes/admin/admin.user.routes.js";
import feedbackRoutes from "./routes/feedback/feedback.js";
import chatbotRoutes from "./routes/chatbot/chatbot.routes.js"
import adminAstroRoutes from "./routes/admin/adminAstrologyRoutes.js";
import invoiceRoutes from "./routes/invoice/invoiceRoutes.js";
import discountRoutes from "./routes/admin/discountRoutes.js";
import unifiedRoutes from "./routes/unified/unified.routes.js";

import shippingRoutes from "./routes/shipping/shipping.js";
import couponRoutes from "./routes/admin/coupons.js";
import notificationRoutes from "./routes/notification/notificationRoutes.js";
import { startUnifiedInternalServices } from "./service/unifiedServiceLauncher.js";





// ==================================================

const app = express();
app.set("trust proxy", 1);

const PORT = process.env.PORT || 8001;

// ================= ESM DIRNAME =================
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ================= INTERNAL SERVICE LAUNCHER =================
startUnifiedInternalServices({ backendDir: __dirname });

// ================= DATABASE =================
const shouldSkipDb = String(process.env.SKIP_DB || "").toLowerCase() === "true";
if (shouldSkipDb) {
  console.log("SKIP_DB=true -> skipping MongoDB connection");
} else {
  connectToMongoDB(process.env.MONGODB_URI)
    .then(() => console.log("MongoDB connected"))
    .catch((err) => {
      console.error("MongoDB connection error:", err);
      process.exit(1);
    });
}

// ================= VIEW ENGINE =================
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

// ================= GLOBAL MIDDLEWARE =================
app.use(cors({ origin: true, credentials: true }));
app.use(morgan("dev"));
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// ================= STATIC FOLDER FOR CHART IMAGES =================
// This makes saved birth chart images publicly accessible

app.use(
  "/charts",
  express.static(path.join(__dirname, "controllers/charts"))
);


// ================= PUBLIC APIs =================
app.use("/api/predictions", predictionsRoute);
app.use("/api/birthchart", birthChartRoute); // Birth chart generation + DB save
app.use("/api/chatbot", chatbotRoutes);
app.use("/api/unified", unifiedRoutes);

// ================= INVOICE ROUTES =================
app.use("/api/invoice", invoiceRoutes);


app.use("/api/v1/compatibility", compatibilityRoute);
app.use("/api/horoscope", horoscopeRoute);

// ================= ADMIN APIs =================
app.use("/api/admin/auth", adminAuthRoutes);
app.use("/api/admin/products", adminProductRoutes);
app.use("/api/admin/users", adminUserRoutes);
app.use("/api/admin/orders", adminOrderRoutes);
app.use("/api/admin/cms", adminCMSRoutes);
app.use("/api/admin/dashboard", adminDashboardRoutes);
app.use("/api/admin/categories", adminCategoryRoutes);
app.use("/api/feedback", feedbackRoutes);
app.use("/api/tarot", tarotRoutes);
app.use("/api/admin/astrology", adminAstroRoutes);

// Mount discount routes under /discount
app.use("/api/discount", discountRoutes);


app.use("/api/shipping", shippingRoutes);

// Coupons
app.use("/api/coupon", couponRoutes);

// Notifications
app.use("/api/notifications", notificationRoutes);


// ================= HEALTH CHECK =================
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    uptime: process.uptime(),
    time: new Date()
  });
});

// ================= SHORT URL REDIRECT =================
app.get("/url/:shortId", async (req, res) => {
  try {
    const entry = await URL.findOneAndUpdate(
      { shortId: req.params.shortId },
      { $push: { visitHistory: { timestamp: new Date() } } },
      { new: true }
    );

    if (!entry) {
      return res.status(404).json({ error: "URL not found" });
    }

    return res.redirect(entry.redirectURL);
  } catch (err) {
    console.error("Redirect error:", err);
    res.status(500).json({ error: "Server error" });
  }
});

// ================= PROTECTED URL API =================
app.use("/api/url", authenticateToken, urlRoute);

// ================= USER AUTH =================
app.use("/user", userRoute);

// ================= STATIC PAGES =================
app.use("/", optionalAuth, staticRoute);

// ================= 404 HANDLER =================
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

// ================= GLOBAL ERROR HANDLER =================
app.use((err, req, res, next) => {
  console.error("Unhandled error:", err);
  res.status(500).json({
    error: err.message || "Internal Server Error"
  });
});

// ================= START SERVER =================
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
