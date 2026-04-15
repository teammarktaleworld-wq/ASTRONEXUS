import Feedback from "../models/shop/feedback.model.js";
import Product from "../models/shop/Product.model.js";
import mongoose from "mongoose";


/* -------------------------------------------------------
   Helper: Recalculate and update product rating summary
--------------------------------------------------------*/
const updateProductRating = async (productId) => {
  const stats = await Feedback.aggregate([
    { $match: { productId: new mongoose.Types.ObjectId(productId) } },
    {
      $group: {
        _id: "$productId",
        avgRating: { $avg: "$rating" },
        reviewCount: { $sum: 1 },
      },
    },
  ]);

  if (stats.length > 0) {
    await Product.findByIdAndUpdate(productId, {
      averageRating: Number(stats[0].avgRating.toFixed(1)),
      numReviews: stats[0].reviewCount,
    });
  } else {
    await Product.findByIdAndUpdate(productId, {
      averageRating: 0,
      numReviews: 0,
    });
  }
};


/* -------------------------------------------------------
   ⭐ Create Review / Rating
--------------------------------------------------------*/
export const createFeedback = async (req, res) => {
  try {
    const { productId, rating, description } = req.body;

    // ✅ Extract user info from middleware
    const userId = req.userId;
    const user = req.user;

    // 🔐 Basic validations
    if (!productId || !rating) {
      return res.status(400).json({
        success: false,
        message: "Product ID and rating are required",
      });
    }

    if (rating < 1 || rating > 5) {
      return res.status(400).json({
        success: false,
        message: "Rating must be between 1 and 5",
      });
    }

    if (!userId || !user?.name) {
      return res.status(401).json({
        success: false,
        message: "User information missing",
      });
    }

    // 🚫 Prevent duplicate review (per user per product)
    const existingReview = await Feedback.findOne({
      productId,
      userId: userId,
    });

    if (existingReview) {
      return res.status(400).json({
        success: false,
        message: "You have already reviewed this product",
      });
    }

    // ✅ Create feedback
    const feedback = new Feedback({
      productId,
      userId: userId,
      userName: user.name,
      userDisplay: user.astrologyProfile || "",
      rating,
      description,
    });

    await feedback.save();

    // ⭐ Update product rating stats
    await updateProductRating(productId);

    return res.status(201).json({
      success: true,
      message: "Review submitted successfully",
      feedback,
    });
  } catch (err) {
    console.error("CREATE FEEDBACK ERROR:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Internal server error",
    });
  }
};

/* -------------------------------------------------------
   ⭐ Get Reviews for a Single Product
--------------------------------------------------------*/
export const getFeedbackByProduct = async (req, res) => {
  try {
    const { productId } = req.params;

    const feedbacks = await Feedback.find({ productId })
      .sort({ createdAt: -1 })
      .select("userName userDisplay rating description createdAt");

    res.status(200).json({ success: true, feedbacks });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};


/* -------------------------------------------------------
   ⭐ Admin: Get All Reviews
--------------------------------------------------------*/
export const getAllFeedbacks = async (req, res) => {
  try {
    const feedbacks = await Feedback.find()
      .sort({ createdAt: -1 })
      .populate("productId", "name averageRating numReviews")
      .populate("userId", "name email");

    res.status(200).json({ success: true, feedbacks });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

/* -------------------------------------------------------
   ⭐ Delete Feedback (User or Admin)
--------------------------------------------------------*/

export const deleteFeedback = async (req, res) => {
  try {
    const { feedbackId } = req.params;

    // ✅ JWT data from middleware
    const userId = req.userId;
    const user = req.user;

    // 1️⃣ Validate feedback ID
    if (!mongoose.Types.ObjectId.isValid(feedbackId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid feedback ID",
      });
    }

    // 2️⃣ Find feedback
    const feedback = await Feedback.findById(feedbackId);
    if (!feedback) {
      return res.status(404).json({
        success: false,
        message: "Feedback not found",
      });
    }

    // 3️⃣ Ensure required auth data exists
    if (!userId || !feedback.userId) {
      return res.status(401).json({
        success: false,
        message: "User information missing",
      });
    }

    // 4️⃣ Authorization check
    const isOwner = feedback.userId.toString() === userId.toString();
    const isAdmin = user?.role === "admin";

    if (!isOwner && !isAdmin) {
      return res.status(403).json({
        success: false,
        message: "You are not allowed to delete this feedback",
      });
    }

    const productId = feedback.productId;

    // 5️⃣ Delete feedback
    await feedback.deleteOne();

    // 6️⃣ Recalculate product rating
    await updateProductRating(productId);

    // 7️⃣ Success response
    return res.status(200).json({
      success: true,
      message: "Feedback deleted successfully",
    });

  } catch (err) {
    console.error("Delete feedback error:", err);
    return res.status(500).json({
      success: false,
      message: err.message || "Server error",
    });
  }
};



