import multer from "multer";
import { CloudinaryStorage } from "multer-storage-cloudinary";
import cloudinary from "../service/config/cloudinary.js";

const profileStorage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "users/profile-images",
    allowed_formats: ["jpg", "jpeg", "png", "webp"],
    transformation: [{ width: 400, height: 400, crop: "limit" }],
  },
});

const uploadProfile = multer({
  storage: profileStorage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB
});

export default uploadProfile;
