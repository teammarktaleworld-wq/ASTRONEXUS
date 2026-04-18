const AstrologyService = require("../../models/features/astrologyServiceModel.js");

exports.createService = async (req, res) => {
  try {
    const { name, key, description, enabled, isPremium } = req.body;
    if (!name || !key) {
      return res.status(400).json({ success: false, message: "Name and key are required" });
    }
    const service = await AstrologyService.create({ name, key, description, enabled, isPremium });
    res.status(201).json({ success: true, data: service });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getAllServices = async (req, res) => {
  try {
    const services = await AstrologyService.find();
    res.json({ success: true, data: services });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getServiceById = async (req, res) => {
  try {
    const { id } = req.params;
    const service = await AstrologyService.findById(id);
    if (!service) return res.status(404).json({ success: false, message: "Service not found" });
    res.json({ success: true, data: service });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateService = async (req, res) => {
  try {
    const { id } = req.params;
    const update = req.body;
    const service = await AstrologyService.findByIdAndUpdate(id, update, { new: true });
    if (!service) return res.status(404).json({ success: false, message: "Service not found" });
    res.json({ success: true, data: service });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.deleteService = async (req, res) => {
  try {
    const { id } = req.params;
    const service = await AstrologyService.findByIdAndDelete(id);
    if (!service) return res.status(404).json({ success: false, message: "Service not found" });
    res.json({ success: true, message: "Service deleted" });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.toggleService = async (req, res) => {
  try {
    const { id } = req.params;
    const { enabled } = req.body;
    const service = await AstrologyService.findByIdAndUpdate(id, { enabled }, { new: true });
    if (!service) return res.status(404).json({ success: false, message: "Service not found" });
    res.json({ success: true, data: service });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
