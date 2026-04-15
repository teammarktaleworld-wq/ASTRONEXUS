const FeatureFlag = require("../models/features/featureFlagModel");

exports.checkFeatureEnabled = (featureKey) => async (req, res, next) => {
  const feature = await FeatureFlag.findOne({ key: featureKey });

  if (!feature || !feature.enabled) {
    return res.status(403).json({
      success: false,
      message: `${featureKey} feature is currently disabled by admin`
    });
  }

  req.featureKey = featureKey;
  console.log("Feature key set:", req.featureKey);

  next();
};
