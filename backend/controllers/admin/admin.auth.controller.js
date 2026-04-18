import jwt from "jsonwebtoken";
import bcrypt from "bcrypt";
import Admin from "../../models/shop/admin.js";

// ==========================
// 🔑 ADMIN LOGIN
// ==========================
export const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const admin = await Admin.findOne({ email });
    if (!admin) {
      return res.status(401).json({ message: "Invalid admin credentials" });
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid admin credentials" });
    }

    const token = jwt.sign(
      { id: admin._id, role: "admin" },
      process.env.JWT_SECRET,
      { expiresIn: "1d" }
    );

    res.status(200).json({
      message: "Login successful",
      token,
    });
  } catch (error) {
    console.error("Login Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ==========================
// 🔧 CREATE ADMIN (WITH SETUP KEY)
// ==========================
export const createAdmin = async (req, res) => {
  try {
    const { email, password, setupKey } = req.body;

    // 🔍 Debug logs (for setup key issues)
    console.log("ENV KEY:", process.env.ADMIN_SETUP_KEY);
    console.log("BODY KEY:", setupKey);

    if (!setupKey || setupKey !== process.env.ADMIN_SETUP_KEY) {
      return res.status(403).json({ message: "Not authorized to create admin" });
    }

    // Check if admin already exists
    const existingAdmin = await Admin.findOne({ email });
    if (existingAdmin) {
      return res.status(400).json({ message: "Admin already exists" });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    const admin = await Admin.create({
      email,
      password: hashedPassword,
    });

    res.status(201).json({
      message: "Admin created successfully",
      admin: { id: admin._id, email: admin.email },
    });
  } catch (error) {
    console.error("Create Admin Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// ==========================
// 🔁 UPDATE PASSWORD
// ==========================
export const updatePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({
        message: "Old password and new password required",
      });
    }

    const admin = await Admin.findById(req.user.id);
    if (!admin) return res.status(404).json({ message: "Admin not found" });

    const isMatch = await bcrypt.compare(oldPassword, admin.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Old password is wrong" });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    admin.password = hashedPassword;
    await admin.save();

    res.status(200).json({ message: "Password updated successfully" });
  } catch (error) {
    console.error("Update Password Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

// 🔹 GET ALL ADMINS
export const getAllAdmins = async (req, res) => {
  try {
    const admins = await Admin.find({}, { password: 0 }); // exclude passwords
    res.status(200).json({
      message: "Admins fetched successfully",
      admins
    });
  } catch (error) {
    console.error("Get All Admins Error:", error);
    res.status(500).json({ message: "Server error" });
  }
};


// ==========================
// 🚪 LOGOUT
// ==========================
export const logout = async (req, res) => {
  res.status(200).json({ message: "Logout successful" });
};


