const express = require("express");
const {
  handleGenerateNewShortURL,
  handleGetAnalytics,
  handleGetAllUrls,
  handleDeleteUrl,
} = require("../controllers/url");

const router = express.Router();

router.post("/", handleGenerateNewShortURL);
router.get("/", handleGetAllUrls);
router.get("/analytics/:shortId", handleGetAnalytics);
router.delete("/:shortId", handleDeleteUrl);

module.exports = router;
