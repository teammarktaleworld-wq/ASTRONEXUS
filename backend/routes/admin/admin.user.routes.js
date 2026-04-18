import express from "express";
import {
  getAllUsers,
  toggleUserBlock,
  deleteUser,
  createUserByAdmin
} from "../../controllers/admin/admin.user.controller.js";

import { authenticateToken } from "../../middlewares/auth.js";
import isAdmin from "../../middlewares/admin.middleware.js";

const router = express.Router();

router.get("/", authenticateToken, isAdmin, getAllUsers);
router.post("/", authenticateToken, isAdmin, createUserByAdmin);
router.patch("/:id/block", authenticateToken, isAdmin, toggleUserBlock);
router.delete("/:id", authenticateToken, isAdmin, deleteUser);

export default router;
