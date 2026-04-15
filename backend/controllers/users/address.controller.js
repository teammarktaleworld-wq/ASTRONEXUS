import Address from "../../models/shop/address.js";

// Get all addresses for the logged-in user
export const getUserAddresses = async (req, res) => {
  try {
    const addresses = await Address.find({ userId: req.userId });
    res.status(200).json(addresses);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Add a new address
export const addAddress = async (req, res) => {
  try {
    const newAddress = new Address({ userId: req.userId, ...req.body });

    // If setting as default, unset other defaults
    if (req.body.isDefault) {
      await Address.updateMany(
        { userId: req.user.id, isDefault: true },
        { isDefault: false }
      );
    }

    const savedAddress = await newAddress.save();
    res.status(201).json(savedAddress);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Update an address
export const updateAddress = async (req, res) => {
  try {
    const updated = await Address.findOneAndUpdate(
      { _id: req.params.addressId, userId: req.userId },
      req.body,
      { new: true }
    );
    if (!updated) return res.status(404).json({ message: "Address not found" });
    res.status(200).json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Delete an address
export const deleteAddress = async (req, res) => {
  try {
    const { addressId } = req.params;
    const requester = req.user; // from authenticateToken

    let address;

    // 🔐 Admin can delete any address
    if (requester.role === "admin") {
      address = await Address.findById(addressId);
    } 
    // 👤 User can delete only their own address
    else {
      address = await Address.findOne({
        _id: addressId,
        userId: req.userId,
      });
    }

    if (!address) {
      return res.status(404).json({ message: "Address not found" });
    }

    const userId = address.userId;
    const wasDefault = address.isDefault;

    await address.deleteOne();

    // ⭐ If default address deleted, promote another one
    if (wasDefault) {
      const anotherAddress = await Address.findOne({ userId });
      if (anotherAddress) {
        anotherAddress.isDefault = true;
        await anotherAddress.save();
      }
    }

    res.status(200).json({
      success: true,
      message:
        requester.role === "admin"
          ? "Address deleted by admin"
          : "Address deleted successfully",
    });
  } catch (err) {
    console.error("Delete address error:", err);
    res.status(500).json({ message: "Failed to delete address" });
  }
};



// Admin: get all addresses
export const getAllAddresses = async (req, res) => {
  try {
    const addresses = await Address.find().populate("userId", "fullName email"); 
    res.status(200).json(addresses);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

