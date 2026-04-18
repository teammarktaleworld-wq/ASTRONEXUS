const CMS = require("../../models/shop/CMSContent.model");

exports.create = async (req, res) => {
  res.json(await CMS.create(req.body));
};

exports.getAll = async (req, res) => {
  res.json(await CMS.find());
};

exports.update = async (req, res) => {
  res.json(await CMS.findByIdAndUpdate(req.params.id, req.body, { new: true }));
};
