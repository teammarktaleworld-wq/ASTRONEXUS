const express = require("express");
const router = express.Router();
const {
  createService,
  getAllServices,
  getServiceById,
  updateService,
  deleteService,
  toggleService
} = require("../../controllers/services/astrologyServiceController.js");
const { authenticateToken } = require("../../middlewares/auth.js");
const adminMiddleware = require("../../middlewares/admin.middleware.js");

// All routes are admin protected
router.use(authenticateToken, adminMiddleware);

router.post("/", createService);
router.get("/", getAllServices);
router.get("/:id", getServiceById);
router.put("/:id", updateService);
router.delete("/:id", deleteService);
router.patch("/:id/toggle", toggleService);

module.exports = router;
