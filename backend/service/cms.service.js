const CMS = require("../models/CMSContent");

exports.getActiveContent = () => {
  return CMS.find({ isActive: true });
};
