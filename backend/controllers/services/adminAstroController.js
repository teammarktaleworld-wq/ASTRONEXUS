const FeatureFlag = require("../../models/features/featureFlagModel.js");
const FeatureUsage = require("../../models/features/featureUsageModel.js");

exports.getAstrologyDashboard = async (req, res) => {
  const features = await FeatureFlag.find();

  const stats = await Promise.all(features.map(async (f) => {
    const totalUsage = await FeatureUsage.countDocuments({ featureKey: f.key });

    return {
      key: f.key,
      name: f.name,
      enabled: f.enabled,
      premium: f.isPremium,
      usageCount: totalUsage
    };
  }));

  res.json({ success: true, data: stats });
};

exports.toggleFeature = async (req, res) => {
  const { key, enabled } = req.body;

  if (!key) {
    return res.status(400).json({
      success: false,
      message: "key is required"
    });
  }

  const feature = await FeatureFlag.findOneAndUpdate(
    { key },
    {
      key,
      name: key.replace("_", " ").toUpperCase(),
      enabled
    },
    {
      new: true,
      upsert: true   // ⭐ THIS IS THE FIX
    }
  );

  res.json({ success: true, data: feature });
};

