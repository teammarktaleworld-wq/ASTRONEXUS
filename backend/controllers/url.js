const { nanoid } = require("nanoid");
const validator = require("validator");
const URL = require("../models/url");

async function handleGenerateNewShortURL(req, res) {
  try {
    const { url, customShortId } = req.body;

    // Validation
    if (!url) {
      return res.status(400).json({ error: "URL is required" });
    }

    if (!validator.isURL(url, { require_protocol: true })) {
      return res.status(400).json({ error: "Invalid URL format. Must include protocol (http:// or https://)" });
    }

    // Generate or use custom short ID
    let shortID;
    if (customShortId) {
      // Validate custom short ID
      if (!/^[a-zA-Z0-9_-]+$/.test(customShortId)) {
        return res.status(400).json({ error: "Custom short ID can only contain letters, numbers, hyphens, and underscores" });
      }

      // Check if custom ID already exists
      const existing = await URL.findOne({ shortId: customShortId });
      if (existing) {
        return res.status(400).json({ error: "Custom short ID already taken" });
      }

      shortID = customShortId;
    } else {
      shortID = nanoid(8);
    }

    // Create short URL
    const urlDoc = await URL.create({
      shortId: shortID,
      redirectURL: url,
      visitHistory: [],
      createdBy: req.user._id,
    });

    return res.status(201).json({
      success: true,
      message: "Short URL created successfully",
      data: {
        shortId: urlDoc.shortId,
        originalUrl: urlDoc.redirectURL,
        shortUrl: `${process.env.BASE_URL}/url/${urlDoc.shortId}`,
        createdAt: urlDoc.createdAt,
      },
    });
  } catch (error) {
    console.error("Create short URL error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

async function handleGetAnalytics(req, res) {
  try {
    const { shortId } = req.params;

    const urlDoc = await URL.findOne({ shortId });

    if (!urlDoc) {
      return res.status(404).json({ error: "Short URL not found" });
    }

    // Check if user owns this URL
    if (urlDoc.createdBy.toString() !== req.user._id) {
      return res.status(403).json({ error: "Access denied. You don't own this URL" });
    }

    return res.json({
      success: true,
      data: {
        shortId: urlDoc.shortId,
        originalUrl: urlDoc.redirectURL,
        totalClicks: urlDoc.visitHistory.length,
        createdAt: urlDoc.createdAt,
        analytics: urlDoc.visitHistory,
      },
    });
  } catch (error) {
    console.error("Get analytics error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

async function handleGetAllUrls(req, res) {
  try {
    const urls = await URL.find({ createdBy: req.user._id }).sort({ createdAt: -1 });

    return res.json({
      success: true,
      count: urls.length,
      data: urls.map((url) => ({
        shortId: url.shortId,
        originalUrl: url.redirectURL,
        shortUrl: `${process.env.BASE_URL}/url/${url.shortId}`,
        clicks: url.visitHistory.length,
        createdAt: url.createdAt,
      })),
    });
  } catch (error) {
    console.error("Get all URLs error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

async function handleDeleteUrl(req, res) {
  try {
    const { shortId } = req.params;

    const urlDoc = await URL.findOne({ shortId });

    if (!urlDoc) {
      return res.status(404).json({ error: "Short URL not found" });
    }

    // Check if user owns this URL
    if (urlDoc.createdBy.toString() !== req.user._id) {
      return res.status(403).json({ error: "Access denied. You don't own this URL" });
    }

    await URL.deleteOne({ shortId });

    return res.json({
      success: true,
      message: "Short URL deleted successfully",
    });
  } catch (error) {
    console.error("Delete URL error:", error);
    return res.status(500).json({ error: "Internal server error" });
  }
}

module.exports = {
  handleGenerateNewShortURL,
  handleGetAnalytics,
  handleGetAllUrls,
  handleDeleteUrl,
};
