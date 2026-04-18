const FeatureUsage = require("../models/features/featureUsageModel");

exports.trackFeatureUsage = async (req, res, next) => {
  res.on("finish", async () => {
    if (res.statusCode < 400 && req.featureKey) {
      await FeatureUsage.create({
        featureKey: req.featureKey,
        userId: req.user?._id || null
      });
    }
  });

  next();
};
