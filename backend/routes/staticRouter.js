const express = require("express");
const URL = require("../models/url");

const router = express.Router();

router.get("/", async (req, res) => {
  try {
    if (!req.user) return res.redirect("/login");
    const allurls = await URL.find({ createdBy: req.user._id }).sort({ createdAt: -1 });
    return res.render("home", {
      urls: allurls,
      baseUrl: process.env.BASE_URL,
    });
  } catch (error) {
    console.error("Home page error:", error);
    return res.status(500).send("Internal server error");
  }
});

router.get("/signup", (req, res) => {
  return res.render("signup");
});

router.get("/login", (req, res) => {
  return res.render("login");
});

module.exports = router;
