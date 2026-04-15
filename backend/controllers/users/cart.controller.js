import mongoose from "mongoose";
import Product from "../../models/shop/Product.model.js";
import Cart from "../../models/shop/Cart.model.js";

/* ----------------------------- ADD TO CART ----------------------------- */
export async function addToCart(req, res) {
  try {
    // 🔒 Ensure authenticated userId is valid ObjectId
    if (!req.userId || !mongoose.Types.ObjectId.isValid(req.userId)) {
      console.error("INVALID USER ID:", req.userId);
      return res.status(401).json({ message: "Invalid user authentication" });
    }

    const userId = req.userId;
    let { productId, quantity } = req.body;

    if (!productId || quantity === undefined) {
      return res.status(400).json({ message: "productId and quantity are required" });
    }

    productId = decodeURIComponent(productId).trim();

    if (!mongoose.Types.ObjectId.isValid(productId)) {
      return res.status(400).json({ message: "Invalid product ID" });
    }

    quantity = Number(quantity);
    if (quantity <= 0) {
      return res.status(400).json({ message: "Quantity must be greater than 0" });
    }

    const product = await Product.findById(productId);
    if (!product || !product.isActive || product.isDeleted) {
      return res.status(400).json({ message: "Invalid or inactive product" });
    }

    let cart = await Cart.findOne({ user: userId });

    if (!cart) {
      cart = await Cart.create({
        user: userId,
        items: []
      });
    }

    const item = cart.items.find(i => i.product.toString() === productId);

    if (item) {
      item.quantity += quantity;
    } else {
      cart.items.push({ product: productId, quantity });
    }

    await cart.save();
    await cart.populate("items.product", "name price images");

    res.json({ success: true, cart });

  } catch (err) {
    console.error("ADD TO CART ERROR:", err);
    res.status(500).json({ message: "Failed to add to cart" });
  }
}

/* ----------------------------- GET CART ----------------------------- */
export async function getCart(req, res) {
  try {
    if (!req.userId || !mongoose.Types.ObjectId.isValid(req.userId)) {
      return res.status(401).json({ message: "Invalid user authentication" });
    }

    const cart = await Cart.findOne({ user: req.userId })
      .populate("items.product", "name price images");

    res.json({
      success: true,
      cart: cart || { items: [] }
    });

  } catch (err) {
    console.error("GET CART ERROR:", err);
    res.status(500).json({ message: "Failed to fetch cart" });
  }
}

/* ----------------------------- REMOVE ITEM ----------------------------- */
export async function removeItem(req, res) {
  try {
    if (!req.userId || !mongoose.Types.ObjectId.isValid(req.userId)) {
      return res.status(401).json({ message: "Invalid user authentication" });
    }

    let productId = req.params.productId;

    if (!productId) {
      return res.status(400).json({ message: "Product ID required" });
    }

    productId = decodeURIComponent(productId).trim();

    if (!mongoose.Types.ObjectId.isValid(productId)) {
      return res.status(400).json({ message: "Invalid product ID" });
    }

    const cart = await Cart.findOne({ user: req.userId });
    if (!cart) {
      return res.status(404).json({ message: "Cart not found" });
    }

    cart.items = cart.items.filter(
      i => i.product.toString() !== productId
    );

    await cart.save();
    await cart.populate("items.product", "name price images");

    res.json({ success: true, cart });

  } catch (err) {
    console.error("REMOVE CART ITEM ERROR:", err);
    res.status(500).json({ message: "Failed to remove item" });
  }
}

/* ----------------------------- UPDATE ITEM ----------------------------- */
export async function updateCartItem(req, res) {
  try {
    if (!req.userId || !mongoose.Types.ObjectId.isValid(req.userId)) {
      return res.status(401).json({ message: "Invalid user authentication" });
    }

    let { productId, quantity } = req.body;

    if (!productId || quantity === undefined) {
      return res.status(400).json({ message: "productId and quantity are required" });
    }

    productId = decodeURIComponent(productId).trim();
    quantity = Number(quantity);

    if (!mongoose.Types.ObjectId.isValid(productId)) {
      return res.status(400).json({ message: "Invalid product ID" });
    }

    if (quantity <= 0) {
      return res.status(400).json({ message: "Quantity must be greater than 0" });
    }

    const cart = await Cart.findOne({ user: req.userId });
    if (!cart) {
      return res.status(404).json({ message: "Cart not found" });
    }

    const item = cart.items.find(i => i.product.toString() === productId);
    if (!item) {
      return res.status(404).json({ message: "Item not found in cart" });
    }

    item.quantity = quantity;

    await cart.save();
    await cart.populate("items.product", "name price images");

    res.json({ success: true, cart });

  } catch (err) {
    console.error("UPDATE CART ITEM ERROR:", err);
    res.status(500).json({ message: "Failed to update cart item" });
  }
}
