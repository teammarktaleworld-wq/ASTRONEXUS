import express from "express";
import { authenticateToken , authorizeAdmin} from "../../middlewares/auth.js";
import upload from "../../middlewares/upload.js";

import {
  handleBasicSignup,
  handleAstrologySignup,
  handleUserLogin,
  handleUserLogout,
  handleUserLoginWithPhone
  , uploadProfileImage, getMyProfile
  , updateMyProfile
  , changePassword
   // ✅ import the new phone login
} from "../../controllers/users/user.js";

import * as categoryController from "../../controllers/users/category.controller.js";
import * as productController from "../../controllers/users/product.controller.js";
import * as cartController from "../../controllers/users/cart.controller.js";
import * as orderController from "../../controllers/users/orderController.js";
import * as paymentController from "../../controllers/users/payment.controller.js";
import * as addressController from "../../controllers/users/address.controller.js";
import { verifyFirebaseOtp } from "../../controllers/users/firebase_auth.js";
import uploadProfile from "../../middlewares/upload.js";
import * as wishlistController from "../../controllers/users/wishlistController.js";
import { getHomeProducts } from "../../controllers/admin/admin.product.controller.js";
import * as walletController from "../../controllers/wallet/walletController.js";





const router = express.Router();

// ================== AUTH ROUTES ==================
router.post("/signup/basic", handleBasicSignup);          // Step 1 signup
router.post("/signup/astrology", handleAstrologySignup);  // Full astrology signup
router.post("/login", handleUserLogin);                   // login by email
router.post("/login/phone", handleUserLoginWithPhone);   // login by phone
router.post("/logout", authenticateToken, handleUserLogout);

router.post(
  "/profile-image",
  authenticateToken,
  upload.single("profileImg"), // ✅ MUST MATCH POSTMAN
  uploadProfileImage
);
router.get("/me", authenticateToken, getMyProfile);
router.put("/me", authenticateToken, updateMyProfile);

router.post("/change-password", authenticateToken, changePassword);

router.post("/verify-otp", verifyFirebaseOtp);


router.get("/home-products", getHomeProducts);


// ================== CATEGORY ROUTES ==================
router.get("/categories", categoryController.getActiveCategories);

// ================== PRODUCT ROUTES ==================
router.get("/products", productController.getProducts);
router.get("/products/:productId", productController.getProductById);

// ================== CART ROUTES ==================
router.get("/cart", authenticateToken, cartController.getCart);
router.post("/cart/add", authenticateToken, cartController.addToCart);
router.put("/cart/update", authenticateToken, cartController.updateCartItem);
router.delete("/cart/remove/:productId", authenticateToken, cartController.removeItem);

// Add item(s) to wishlist or overwrite existing
router.post("/wishlist", authenticateToken, wishlistController.addWishlist);

// Get wishlist for logged-in user
router.get("/wishlist", authenticateToken, wishlistController.getWishlist);

// Remove a product from wishlist
router.delete("/wishlist/remove", authenticateToken, wishlistController.removeProduct);

// ================== ORDER ROUTES ==================
router.post("/orders", authenticateToken, orderController.placeOrder);
router.get("/orders/my", authenticateToken, orderController.getUserOrders);
router.get("/orders/:orderId", authenticateToken, orderController.getOrderById);


// Admin route
router.get("/addresses/all", authenticateToken, authorizeAdmin, addressController.getAllAddresses);
router.delete(
  "/admin/addresses/:addressId",
  authenticateToken,
  authorizeAdmin,
  addressController.deleteAddress
);


//Address

router.get("/addresses", authenticateToken, addressController.getUserAddresses);
router.post("/addresses/add", authenticateToken, addressController.addAddress);
router.put("/addresses/:addressId", authenticateToken, addressController.updateAddress);
router.delete("/addresses/:addressId", authenticateToken, addressController.deleteAddress);


// ================== PAYMENT ROUTES ==================
router.post("/payment/create", authenticateToken, paymentController.createPayment);
router.post("/payment/verify", authenticateToken, paymentController.verifyPayment);


router.get('/:userId', walletController.getWallet);

// deposit money
router.post('/:userId/deposit', walletController.deposit);

// withdraw money
router.post('/:userId/withdraw', walletController.withdraw);



console.log("User routes loaded");

export default router;
