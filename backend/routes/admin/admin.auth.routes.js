import express from "express";
import {
  login,
  updatePassword,
  logout,
  getAllAdmins,
  createAdmin
} from "../../controllers/admin/admin.auth.controller.js";

import { authenticateToken } from "../../middlewares/auth.js";

const router = express.Router();

router.post("/create", createAdmin); // only works with setup key
router.post("/login", login);
router.get("/all", authenticateToken, getAllAdmins);

router.put("/update-password", authenticateToken, updatePassword);
router.post("/logout", authenticateToken, logout);

export default router;
