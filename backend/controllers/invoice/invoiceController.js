import PDFDocument from "pdfkit";
import fs from "fs";
import path from "path";
import QRCode from "qrcode";
import nodemailer from "nodemailer";
import Order from "../../models/shop/Order.model.js";
import { fileURLToPath } from "url";

/* ================= CONFIG ================= */
const GST_RATE = 18;
const COMPANY = "Astronexus Web Pvt Ltd";
const SUPPORT_EMAIL = "support@astronexus.com";
const WEBSITE = "https://astronexus.com";

const getOrderUrl = (id) => `${WEBSITE}/orders/${id}`;
const formatCurrency = (n) => `₹${Number(n).toFixed(2)}`;

/* ================= PATH ================= */
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const invoiceDir = path.join(__dirname, "../../invoices");

if (!fs.existsSync(invoiceDir)) fs.mkdirSync(invoiceDir, { recursive: true });

/* ================= EMAIL ================= */
const mailer = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false,
  auth: {
    user: process.env.SMTP_EMAIL,
    pass: process.env.SMTP_PASSWORD,
  },
});

/* ================= PDF BUILDER ================= */
const buildInvoicePdf = async (doc, order) => {
  const orderUrl = getOrderUrl(order._id);

  const subtotal = order.items.reduce(
    (sum, i) => sum + i.price * i.quantity,
    0
  );
  const gstAmount = (subtotal * GST_RATE) / 100;
  const grandTotal = subtotal + gstAmount;

  const pageWidth = doc.page.width;
  const pageHeight = doc.page.height;
  const centerX = pageWidth / 2;

  /* HEADER */
  doc.rect(0, 0, pageWidth, 8).fill("#0f3c5f");
  doc.fillColor("#0f3c5f").font("Helvetica-Bold").fontSize(22)
    .text("ASTRONEXUS", 40, 30);
  doc.fontSize(10).fillColor("#555")
    .text("Premium Astrology & Digital Products", 40, 55);
  doc.font("Helvetica-Bold").fontSize(18).fillColor("#000")
    .text("INVOICE", 0, 40, { align: "right" });

  /* META */
  let y = 90;
  doc.rect(40, y, pageWidth - 80, 120).stroke("#dcdcdc");

  doc.fontSize(10).fillColor("#333");
  doc.font("Helvetica-Bold").text("Bill To:", 50, y + 10);
  doc.font("Helvetica")
    .text(order.user.fullName, 50, y + 25)
    .text(order.user.email, 50, y + 40);

  if (order.address) {
    doc.text(
      Object.values(order.address).filter(Boolean).join(", "),
      50,
      y + 55,
      { width: 240 }
    );
  }

  doc.font("Helvetica-Bold").text("Invoice ID:", 320, y + 10);
  doc.fillColor("#0f3c5f")
    .text(order._id.toString(), 400, y + 10, {
      link: orderUrl,
      underline: true,
    });

  doc.fillColor("#333");
  doc.font("Helvetica-Bold").text("Date:", 320, y + 30);
  doc.font("Helvetica").text(new Date().toLocaleDateString(), 400, y + 30);

  /* PRODUCTS */
  let tableTop = y + 145;
  const col = { name: 95, qty: 310, price: 370, total: 450 };

  doc.rect(40, tableTop, pageWidth - 80, 25).fill("#0f3c5f");
  doc.fillColor("#fff").font("Helvetica-Bold").fontSize(10)
    .text("Product", col.name, tableTop + 7)
    .text("Qty", col.qty, tableTop + 7)
    .text("Price", col.price, tableTop + 7)
    .text("Total", col.total, tableTop + 7);

  tableTop += 25;
  doc.fillColor("#000").font("Helvetica");

  order.items.forEach((item) => {
    doc.rect(40, tableTop, pageWidth - 80, 40).stroke("#e6e6e6");
    doc.text(item.product.name, col.name, tableTop + 12, { width: 200 });
    doc.text(item.quantity, col.qty, tableTop + 12);
    doc.text(formatCurrency(item.price), col.price, tableTop + 12);
    doc.text(formatCurrency(item.price * item.quantity), col.total, tableTop + 12);
    tableTop += 40;
  });

  /* TOTAL */
  const boxX = centerX - 160;
  doc.rect(boxX, tableTop + 20, 320, 90).stroke("#0f3c5f");
  doc.font("Helvetica-Bold")
    .text("Subtotal", boxX + 20, tableTop + 35)
    .text(`GST (${GST_RATE}%)`, boxX + 20, tableTop + 55)
    .text("Grand Total", boxX + 20, tableTop + 75);

  doc.font("Helvetica")
    .text(formatCurrency(subtotal), boxX + 200, tableTop + 35)
    .text(formatCurrency(gstAmount), boxX + 200, tableTop + 55)
    .text(formatCurrency(grandTotal), boxX + 200, tableTop + 75);

  /* QR */
  const qr = await QRCode.toBuffer(orderUrl);
  doc.image(qr, centerX - 45, tableTop + 130, { width: 90 });

  /* FOOTER */
  doc.fontSize(8).fillColor("#555")
    .text(`Digitally signed by ${COMPANY}`, 0, pageHeight - 60, { align: "center" });
  doc.rect(0, pageHeight - 20, pageWidth, 20).fill("#0f3c5f");
  doc.fillColor("#fff").fontSize(8)
    .text("Thank you for shopping with Astronexus", 0, pageHeight - 15, { align: "center" });
};

/* ================= SAVE PDF ================= */
export const saveInvoicePdf = async (orderId) => {
  const order = await Order.findById(orderId)
    .populate("items.product", "name price")
    .populate("user", "fullName email")
    .populate("address");

  if (!order) throw new Error("Order not found");

  const filePath = path.join(invoiceDir, `invoice_${orderId}.pdf`);
  const doc = new PDFDocument({ size: "A4", margin: 40 });
  doc.pipe(fs.createWriteStream(filePath));

  await buildInvoicePdf(doc, order);
  doc.end();

  return filePath;
};

/* ================= EXPORTS FOR ROUTES ================= */

// Sends a JSON response with the generated invoice path
export const generateInvoice = async (req, res) => {
  try {
    const filePath = await saveInvoicePdf(req.params.orderId);
    res.status(200).json({ message: "Invoice generated successfully", path: filePath });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};

// Preview invoice in browser
export const previewInvoice = async (req, res) => {
  try {
    const filePath = await saveInvoicePdf(req.params.orderId);
    const stream = fs.createReadStream(filePath);
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader("Content-Disposition", "inline; filename=invoice.pdf");
    stream.pipe(res);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};

// Download invoice as PDF
export const downloadInvoice = async (req, res) => {
  try {
    const filePath = await saveInvoicePdf(req.params.orderId);
    res.download(filePath, `invoice_${req.params.orderId}.pdf`);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};
