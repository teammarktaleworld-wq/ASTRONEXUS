// controllers/notificationController.js
import Notification from "../../models/notification/Notification.js";
import User from "../../models/user/user.js"; // make sure path is correct

/**
 * Get all notifications
 * - Admin: all notifications
 * - User: only their notifications
 */
export const getNotifications = async (req, res) => {
  try {
    let notifications;

    if (req.user.role === "admin") {
      notifications = await Notification.find().sort({ createdAt: -1 });
    } else {
      notifications = await Notification.find({ userId: req.user._id }).sort({ createdAt: -1 });
    }

    res.json(notifications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/**
 * Mark a notification as read
 */
export const markAsRead = async (req, res) => {
  const { notificationId } = req.params;
  try {
    const notification = await Notification.findByIdAndUpdate(
      notificationId,
      { read: true },
      { new: true }
    );
    if (!notification) return res.status(404).json({ message: "Notification not found" });
    res.json(notification);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

/**
 * Create a notification (Admin only)
 * Supports sending to:
 * - A specific user (userId)
 * - All users (broadcast: true)
 */
export const createNotification = async (req, res) => {
  const { userId, type, title, message, broadcast } = req.body;

  try {
    if (!title || !message) {
      return res.status(400).json({ message: "Title and message are required" });
    }

    // Broadcast to all users
    if (broadcast) {
      const users = await User.find({}, "_id");
      const notifications = users.map(u => ({
        userId: u._id,
        type: type || "system",
        title,
        message,
      }));
      await Notification.insertMany(notifications);
      return res.status(201).json({ message: `Notification sent to ${users.length} users` });
    }

    // Single user notification
    if (!userId) return res.status(400).json({ message: "User ID required for single notification" });

    const notification = new Notification({
      userId,
      type: type || "system",
      title,
      message,
    });

    await notification.save();
    res.status(201).json(notification);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
};