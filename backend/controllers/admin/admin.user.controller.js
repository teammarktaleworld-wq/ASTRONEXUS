import User from "../../models/user/user.js";
import bcrypt from "bcryptjs";

/**
 * GET /api/admin/users
 */
export const getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password");
    res.json(users);
  } catch (err) {
    console.error("GET USERS ERROR:", err);
    res.status(500).json({ error: err.message });
  }
};

export const createUserByAdmin = async (req, res) => {
  try {
    const { name, email, phone, password, role = "user" } = req.body;

    if (!name || !email || !phone || !password) {
      return res.status(400).json({ message: "All fields are required" });
    }

    const exists = await User.findOne({ email });
    if (exists) {
      return res.status(400).json({ message: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      phone,
      password: hashedPassword,
      role,
    });

    res.status(201).json({
      success: true,
      message: "User created successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
      },
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


export const toggleUserBlock = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user || user.role === "admin") {
      return res.status(403).json({ message: "Action not allowed" });
    }

    user.isBlocked = !user.isBlocked;
    await user.save();

    res.json({ success: true, isBlocked: user.isBlocked });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

export const deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user || user.role === "admin") {
      return res.status(403).json({ message: "Action not allowed" });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({ success: true, message: "User deleted successfully" });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
