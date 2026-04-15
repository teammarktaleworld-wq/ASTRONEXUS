import { Router } from "express";
import { authenticateToken } from "../../middlewares/auth.js";
import adminOnly from "../../middlewares/admin.middleware.js";
import { getDashboardOverview } from "../../controllers/admin/admin.dashboard.controller.js";

const router = Router();

router.get("/", authenticateToken, adminOnly, getDashboardOverview);

export default router;
