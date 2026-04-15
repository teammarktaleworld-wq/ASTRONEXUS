import bcrypt from "bcryptjs";
import validator from "validator";
import User from "../../models/user/user.js";
import { createToken, createRefreshToken, verifyRefreshToken } from "../../service/auth.js";
import cloudinary from "../../service/config/cloudinary.js";
import upload from "../../middlewares/upload.js";     
import { authenticateToken } from "../../middlewares/auth.js";
import BirthChart from "../../models/features/birthChartModel.js";


/* ======================================================
   1️⃣ BASIC SIGNUP
====================================================== */
export async function handleBasicSignup(req, res) {
  try {
    const { name, phone, password, confirmPassword, email } = req.body;

    if (!name || !phone || !password || !confirmPassword) {
      return res.status(400).json({ error: "Name, phone and password are required" });
    }
    if (!validator.isMobilePhone(phone, "any")) {
      return res.status(400).json({ error: "Invalid phone number" });
    }
    if (email && !validator.isEmail(email)) {
      return res.status(400).json({ error: "Invalid email format" });
    }
    if (password.length < 6) {
      return res.status(400).json({ error: "Password must be at least 6 characters" });
    }
    if (password !== confirmPassword) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    const existingUser = await User.findOne({ $or: [{ phone }, { email }] });
    if (existingUser) return res.status(400).json({ error: "User already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({ name, phone, email, password: hashedPassword });

    const token = createToken(user);
    const refreshToken = createRefreshToken(user);

    res.cookie("token", token, { httpOnly: true, maxAge: 7 * 24 * 60 * 60 * 1000 });
    res.cookie("refreshToken", refreshToken, { httpOnly: true, maxAge: 30 * 24 * 60 * 60 * 1000 });

    res.status(201).json({
      success: true,
      message: "Basic signup successful",
      token,
      refreshToken,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        sessionId: user.sessionId   // ⭐ added
      }
    });

  } catch (error) {
    console.error("Basic Signup Error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
}

/* ======================================================
   2️⃣ ASTROLOGY SIGNUP (FULL PROFILE)
====================================================== */
export async function handleAstrologySignup(req, res) {
  try {
    const {
      name,
      phone,
      password,
      confirmPassword,
      email,
      dateOfBirth,
      timeOfBirth,
      placeOfBirth,
      tempChartId // optional: temporary chart generated before signup
    } = req.body;

    // 1️⃣ Basic validations
    if (!dateOfBirth || !timeOfBirth || !placeOfBirth) {
      return res.status(400).json({ error: "Astrology birth details are required" });
    }
    if (!validator.isMobilePhone(phone, "any")) {
      return res.status(400).json({ error: "Invalid phone number" });
    }
    if (email && !validator.isEmail(email)) {
      return res.status(400).json({ error: "Invalid email format" });
    }
    if (!password || password.length < 6) {
      return res.status(400).json({ error: "Password must be at least 6 characters" });
    }
    if (password !== confirmPassword) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    // 2️⃣ Check if user already exists
    const existingUser = await User.findOne({ $or: [{ phone }, { email }] });
    if (existingUser) return res.status(400).json({ error: "User already exists" });

    // 3️⃣ Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // 4️⃣ Create user
    const user = await User.create({
      name,
      phone,
      email,
      password: hashedPassword,
      astrologyProfile: { dateOfBirth, timeOfBirth, placeOfBirth }
    });

    // 5️⃣ Link temporary birth chart (if provided)
    let birthChart = null;
    if (tempChartId) {
      try {
        birthChart = await BirthChart.findById(tempChartId);
        if (birthChart) {
          birthChart.userId = user._id;
          birthChart.isTemporary = false;
          await birthChart.save();
        } else {
          console.warn("Temporary chart not found for ID:", tempChartId);
        }
      } catch (err) {
        console.warn("Failed to link temporary chart:", err.message);
      }
    }

    // 6️⃣ Generate JWT tokens
    const token = createToken(user);
    const refreshToken = createRefreshToken(user);

    // 7️⃣ Set cookies
    res.cookie("token", token, { httpOnly: true, maxAge: 7 * 24 * 60 * 60 * 1000 });
    res.cookie("refreshToken", refreshToken, { httpOnly: true, maxAge: 30 * 24 * 60 * 60 * 1000 });

    // 8️⃣ Return response with user + birth chart
    res.status(201).json({
      success: true,
      message: "Astrology signup successful",
      token,
      refreshToken,
      user: {
        id: user._id,
        name: user.name,
        sessionId: user.sessionId,
        astrologyProfile: user.astrologyProfile,
        birthChart: birthChart
          ? {
              chartImage: birthChart.chartImage,
              chartData: birthChart.chartData,
              rashi: birthChart.rashi,
              isTemporary: birthChart.isTemporary
            }
          : null
      }
    });

  } catch (error) {
    console.error("Astrology Signup Error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
}



/* ======================================================
   USER LOGIN (EMAIL)
====================================================== */
export async function handleUserLogin(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password)
      return res.status(400).json({ error: "Email and password are required" });

    if (!validator.isEmail(email))
      return res.status(400).json({ error: "Invalid email format" });

    // Fetch user including password & astrology profile
    const user = await User.findOne({ email }).select("+password +astrologyProfile");
    if (!user) return res.status(401).json({ error: "Invalid email or password" });
    if (user.isBlocked) return res.status(403).json({ error: "This account is blocked" });

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) return res.status(401).json({ error: "Invalid email or password" });

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    // Generate tokens
    const token = createToken(user);
    const refreshToken = createRefreshToken(user);

    res.cookie("token", token, {
      httpOnly: true,
      maxAge: 7 * 24 * 60 * 60 * 1000
    });
    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      maxAge: 30 * 24 * 60 * 60 * 1000
    });

    // ⭐ Fetch all non-temporary birth charts linked to this user
    const charts = await BirthChart.find({ userId: user._id, isTemporary: false })
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      message: "Login successful",
      token,
      refreshToken,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        isBlocked: user.isBlocked,
        lastLoginAt: user.lastLoginAt,
        sessionId: user.sessionId,
        astrologyProfile: user.astrologyProfile || null,
        charts: charts.map(chart => ({
          id: chart._id,
          chartImage: chart.chartImage,
          chartData: chart.chartData,   // ✅ full JSON data
          rashi: chart.rashi,
          createdAt: chart.createdAt
        })),
        chartsCount: charts.length
      }
    });

  } catch (error) {
    console.error("Login error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

/* ======================================================
   USER LOGIN (PHONE)
====================================================== */
export async function handleUserLoginWithPhone(req, res) {
  try {
    const { phone, password } = req.body;

    if (!phone || !password)
      return res.status(400).json({ error: "Phone and password are required" });

    if (!validator.isMobilePhone(phone, "any"))
      return res.status(400).json({ error: "Invalid phone number format" });

    // Fetch user including password & astrology profile
    const user = await User.findOne({ phone }).select("+password +astrologyProfile");
    if (!user) return res.status(401).json({ error: "Invalid phone or password" });
    if (user.isBlocked) return res.status(403).json({ error: "This account is blocked" });

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) return res.status(401).json({ error: "Invalid phone or password" });

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    // Generate tokens
    const token = createToken(user);
    const refreshToken = createRefreshToken(user);

    res.cookie("token", token, {
      httpOnly: true,
      maxAge: 7 * 24 * 60 * 60 * 1000
    });
    res.cookie("refreshToken", refreshToken, {
      httpOnly: true,
      maxAge: 30 * 24 * 60 * 60 * 1000
    });

    // ⭐ Fetch all non-temporary birth charts linked to this user
    const charts = await BirthChart.find({ userId: user._id, isTemporary: false })
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      message: "Login successful",
      token,
      refreshToken,
      user: {
        id: user._id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        isBlocked: user.isBlocked,
        lastLoginAt: user.lastLoginAt,
        sessionId: user.sessionId,  // ⭐ added
        astrologyProfile: user.astrologyProfile || null,
        charts: charts.map(chart => ({
          id: chart._id,
          chartImage: chart.chartImage,
          chartData: chart.chartData,   // ✅ full JSON data
          rashi: chart.rashi,
          createdAt: chart.createdAt
        })),
        chartsCount: charts.length
      }
    });

  } catch (error) {
    console.error("Login error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}


/// ========================= get my profile =========================

export async function getMyProfile(req, res) {
  try {
    // Fetch user details
    const user = await User.findById(req.user.id).select(
      "name email phone profileImage astrologyProfile sessionId"
    );

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Fetch all linked birth charts (non-temporary)
    const charts = await BirthChart.find({ userId: user._id, isTemporary: false })
      .sort({ createdAt: -1 });

    const chartsCount = charts.length;

    res.json({
      success: true,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        sessionId: user.sessionId,
        profileImage: user.profileImage
          ? {
              publicId: user.profileImage.publicId,
              url: user.profileImage.url,
            }
          : null,
        astrologyProfile: user.astrologyProfile || null,
        charts: charts.map(chart => ({
          id: chart._id,
          chartImage: chart.chartImage,
          chartData: chart.chartData,   // ✅ include full JSON data
          rashi: chart.rashi,
          createdAt: chart.createdAt
        })),
        chartsCount
      }
    });
  } catch (err) {
    console.error("Get profile error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
}


/* ======================================================
   UPDATE MY PROFILE
====================================================== */
export async function updateMyProfile(req, res) {
  try {
    const userId = req.user.id;

    const {
      name,
      email,
      phone,
      astrologyProfile // { dateOfBirth, timeOfBirth, placeOfBirth }
    } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    /* ================= VALIDATIONS ================= */

    if (email && !validator.isEmail(email)) {
      return res.status(400).json({ error: "Invalid email format" });
    }

    if (phone && !validator.isMobilePhone(phone, "any")) {
      return res.status(400).json({ error: "Invalid phone number" });
    }

    // Check email/phone uniqueness
    if (email && email !== user.email) {
      const emailExists = await User.findOne({ email });
      if (emailExists) {
        return res.status(400).json({ error: "Email already in use" });
      }
    }

    if (phone && phone !== user.phone) {
      const phoneExists = await User.findOne({ phone });
      if (phoneExists) {
        return res.status(400).json({ error: "Phone already in use" });
      }
    }

    /* ================= UPDATE FIELDS ================= */

    if (name) user.name = name;
    if (email) user.email = email;
    if (phone) user.phone = phone;

    if (astrologyProfile) {
      user.astrologyProfile = {
        ...user.astrologyProfile,
        ...astrologyProfile
      };
    }

    await user.save();

    return res.json({
      success: true,
      message: "Profile updated successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        astrologyProfile: user.astrologyProfile,
        profileImage: user.profileImage || null,
        sessionId: user.sessionId
      }
    });

  } catch (error) {
    console.error("Update profile error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}


/* ======================================================
   CHANGE PASSWORD
====================================================== */
export async function changePassword(req, res) {
  try {
    const userId = req.user.id;
    const { oldPassword, newPassword, confirmPassword } = req.body;

    if (!oldPassword || !newPassword || !confirmPassword) {
      return res.status(400).json({ error: "All fields are required" });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ error: "Password must be at least 6 characters" });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({ error: "Passwords do not match" });
    }

    const user = await User.findById(userId).select("+password");
    if (!user) return res.status(404).json({ error: "User not found" });

    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) {
      return res.status(401).json({ error: "Old password is incorrect" });
    }

    // Prevent same password reuse
    const isSame = await bcrypt.compare(newPassword, user.password);
    if (isSame) {
      return res.status(400).json({ error: "New password must be different" });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    return res.json({
      success: true,
      message: "Password changed successfully"
    });

  } catch (error) {
    console.error("Change password error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}


/* ======================================================
   REFRESH TOKEN
====================================================== */
export async function handleRefreshToken(req, res) {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) return res.status(401).json({ error: "No refresh token provided" });

    const userData = verifyRefreshToken(refreshToken);
    if (!userData) return res.status(401).json({ error: "Invalid refresh token" });

    const user = await User.findById(userData.id);
    if (!user) return res.status(404).json({ error: "User not found" });

    const newToken = createToken(user);
    const newRefreshToken = createRefreshToken(user);

    res.cookie("token", newToken, { httpOnly: true, maxAge: 7 * 24 * 60 * 60 * 1000 });
    res.cookie("refreshToken", newRefreshToken, { httpOnly: true, maxAge: 30 * 24 * 60 * 60 * 1000 });

    return res.json({
      success: true,
      token: newToken,
      refreshToken: newRefreshToken,
      sessionId: user.sessionId   // ⭐ helpful for frontend re-sync
    });
  } catch (err) {
    console.error("Refresh token error:", err);
    return res.status(500).json({ error: "Internal server error" });
  }
}

// ========================= upload //========================

export const uploadProfileImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No image uploaded" });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    if (user.profileImage?.publicId) {
      await cloudinary.uploader.destroy(user.profileImage.publicId);
    }

    user.profileImage = {
      url: req.file.secure_url,
      publicId: req.file.filename,
    };

    await user.save();

    res.json({
      success: true,
      profileImage: user.profileImage,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Image upload failed" });
  }
};

/* ======================================================
   USER LOGOUT
====================================================== */
export async function handleUserLogout(req, res) {
  res.clearCookie("token");
  res.clearCookie("refreshToken");
  return res.json({ success: true, message: "Logged out successfully" });
}

