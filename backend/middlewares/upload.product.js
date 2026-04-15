import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import cloudinary from "../service/config/cloudinary.js";

const productStorage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "products",
    allowed_formats: ["jpg", "jpeg", "png", "webp"],
  },
});

const uploadProduct = multer({
  storage: productStorage,
  limits: { fileSize: 5 * 1024 * 1024 }, // ✅ 5MB
});

export default uploadProduct;
