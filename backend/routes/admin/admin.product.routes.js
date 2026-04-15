const router = require("express").Router();
const controller = require("../../controllers/admin/admin.product.controller");
const { authenticateToken } = require("../../middlewares/auth");
const admin = require("../../middlewares/admin.middleware");
const uploadProduct = require("../../middlewares/upload.product").default;

// Auth
router.use(authenticateToken);
router.use(admin);

// ================= PRODUCT ROUTES =================

// CREATE PRODUCT (WITH IMAGES)
router.post(
  "/",
  uploadProduct.array("images", 5), // 👈 IMPORTANT
  controller.createProduct
);

router.get("/", controller.getAllProducts);
router.get("/:id", controller.getProductById);

// UPDATE PRODUCT (OPTIONAL IMAGE UPDATE)
router.put(
  "/:id",
  uploadProduct.array("images", 5),
  controller.updateProduct
);

// Delete handling
router.patch("/:id/deactivate", controller.deactivateProduct);
router.delete("/:id", controller.deleteProductPermanent);

module.exports = router;
