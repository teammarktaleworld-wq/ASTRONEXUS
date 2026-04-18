import express from "express";
import {
  generateInvoice,
  previewInvoice,
  downloadInvoice,
} from "../../controllers/invoice/invoiceController.js";

const router = express.Router();

router.get("/generate/:orderId", generateInvoice);
router.get("/preview/:orderId", previewInvoice);
router.get("/download/:orderId", downloadInvoice);

export default router;
