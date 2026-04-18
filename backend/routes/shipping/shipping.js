import express from "express";
import { authenticateToken, authorizeAdmin } from "../../middlewares/auth.js";
import * as shippingController from "../../controllers/users/shippingController.js";

const router = express.Router();

router.get("/", shippingController.getShippingMethods);
router.post("/", authenticateToken, authorizeAdmin, shippingController.createShippingMethod);
router.put("/:shippingId", authenticateToken, authorizeAdmin, shippingController.updateShippingMethod);
router.delete("/:shippingId", authenticateToken, authorizeAdmin, shippingController.deleteShippingMethod);

export default router;