
import Product from "../../models/shop/Product.model.js";
import Category from "../../models/shop/Category.model.js";

/**
 * ================= CREATE PRODUCT =================
 */
export const createProduct = async (req, res) => {
  try {
    const {
      name,
      price,
      category,
      astrologyType,
      stock,
      description,
      isActive,
      deliveryType
    } = req.body;

    // ✅ REQUIRED VALIDATION
    if (!name || price === undefined) {
      return res.status(400).json({ message: "Name and price are required" });
    }

    if (Number(price) <= 0) {
      return res.status(400).json({ message: "Price must be greater than 0" });
    }

    // ✅ CATEGORY VALIDATION
    let categoryId = null;
    if (category) {
      const cat = await Category.findOne({ _id: category, isActive: true });
      if (!cat) {
        return res.status(400).json({ message: "Invalid or inactive category" });
      }
      categoryId = cat._id;
    }

    // ✅ CLOUDINARY IMAGES (THIS IS THE FIX)
    const images = req.files ? req.files.map(file => file.path) : [];

    const product = await Product.create({
      name,
      description,
      price: Number(price),
      stock: stock ?? 0,
      category: categoryId,
      astrologyType: astrologyType || "gemstone",
      images, // ✅ Cloudinary URLs
      deliveryType: deliveryType || "physical",
      isActive: isActive ?? true
    });

    return res.status(201).json({
      success: true,
      message: "Product created successfully",
      product
    });

  } catch (err) {
    console.error("CREATE PRODUCT ERROR:", err);
    return res.status(500).json({
      success: false,
      error: err.message
    });
  }
};

/**
 * ================= GET ALL PRODUCTS (ADMIN) =================
 */
export const getAllProducts = async (req, res) => {
  try {
    const products = await Product.find({ isDeleted: { $ne: true } })
      .populate({
        path: "category",
        select: "name isActive",
        options: { strictPopulate: false }
      })
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      count: products.length,
      products
    });

  } catch (err) {
    console.error("GET PRODUCTS ERROR:", err);
    res.status(500).json({
      success: false,
      message: err.message || "Failed to fetch products"
    });
  }
};



/**
 * ================= GET SINGLE PRODUCT =================
 */
export const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id)
      .populate({
        path: "category",
        select: "name isActive",
        options: { strictPopulate: false }
      });

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.json({
      success: true,
      product
    });
  } catch (err) {
    console.error("GET PRODUCT ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

/**
 * ================= UPDATE PRODUCT =================
 */
export const updateProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ success: false, message: "Product not found" });
    }

    // ✅ CATEGORY VALIDATION
    if (req.body.category) {
      const cat = await Category.findOne({
        _id: req.body.category,
        isActive: true,
      });

      if (!cat) {
        return res.status(400).json({ success: false, message: "Invalid category" });
      }

      req.body.category = cat._id;
    }

    // ❌ REMOVE IMAGES (DB ONLY — Cloudinary safe)
    if (req.body.removedImages) {
      const removedImages = JSON.parse(req.body.removedImages);

      product.images = product.images.filter(
        img => !removedImages.includes(img)
      );
    }

    // ✅ ADD NEW IMAGES
    if (req.files && req.files.length > 0) {
      const newImages = req.files.map(file => file.path);
      product.images.push(...newImages);
    }

    // ✅ UPDATE OTHER FIELDS
    Object.assign(product, req.body);
    await product.save();

    res.json({
      success: true,
      message: "Product updated successfully",
      product,
    });

  } catch (err) {
    console.error("UPDATE PRODUCT ERROR:", err);
    res.status(500).json({
      success: false,
      message: err.message,
    });
  }
};



/**
 * ================= SOFT DELETE (DEACTIVATE) =================
 */
export const deactivateProduct = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    product.isActive = false;
    product.isDeleted = true;
    await product.save();

    res.json({ success: true, message: "Product deactivated successfully" });
  } catch (err) {
    console.error("DEACTIVATE PRODUCT ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};

/**
 * ================= PERMANENT DELETE =================
 */
export const deleteProductPermanent = async (req, res) => {
  try {
    const product = await Product.findByIdAndDelete(req.params.id);

    if (!product) {
      return res.status(404).json({ message: "Product not found" });
    }

    res.json({ success: true, message: "Product permanently deleted" });
  } catch (err) {
    console.error("DELETE PRODUCT ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};


export const getHomeProducts = async (req, res) => {
  try {
    // ✅ First, get active products marked for home
    let products = await Product.find({
      isActive: true,
      isDeleted: false,
      showInHome: true
    })
      .sort({ homePriority: -1, lastShownAt: 1, createdAt: -1 })
      .limit(10);

    // ✅ If less than 3, get fallback products
    if (products.length < 3) {
      const fallback = await Product.find({
        isActive: true,
        isDeleted: false,
        _id: { $nin: products.map(p => p._id) }
      })
        .sort({ createdAt: -1 })
        .limit(3 - products.length);

      products.push(...fallback);
    }

    // ✅ Update lastShownAt for rotation
    const now = new Date();
    await Promise.all(
      products.map(p => Product.findByIdAndUpdate(p._id, { lastShownAt: now }))
    );

    res.status(200).json({
      success: true,
      count: products.length,
      products
    });

  } catch (err) {
    console.error("HOME PRODUCTS ERROR:", err);
    res.status(500).json({ success: false, message: err.message });
  }
};