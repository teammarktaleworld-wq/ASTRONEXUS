import https from "https";
import dotenv from "dotenv";
dotenv.config();

export const getDailyHoroscope = (req, res) => {
  // ✅ Sanitize inputs
  const sign = (req.query.sign || "aquarius").trim().toLowerCase();
  const day = (req.query.day || "today").trim().toLowerCase();

  // ✅ Validate day
  const validDays = ["today", "tomorrow", "yesterday"];
  if (!validDays.includes(day)) {
    return res.status(400).json({
      success: false,
      message: "Invalid day parameter"
    });
  }

  // ✅ Validate sign
  const validSigns = [
    "aries","taurus","gemini","cancer","leo","virgo",
    "libra","scorpio","sagittarius","capricorn","aquarius","pisces"
  ];
  if (!validSigns.includes(sign)) {
    return res.status(400).json({
      success: false,
      message: "Invalid zodiac sign"
    });
  }

  if (!process.env.RAPIDAPI_KEY) {
    return res.status(500).json({
      success: false,
      message: "RapidAPI key not configured"
    });
  }

  const options = {
    method: "POST",
    hostname: "sameer-kumar-aztro-v1.p.rapidapi.com",
    path: `/?sign=${encodeURIComponent(sign)}&day=${encodeURIComponent(day)}`,
    headers: {
      "x-rapidapi-key": process.env.RAPIDAPI_KEY,
      "x-rapidapi-host": "sameer-kumar-aztro-v1.p.rapidapi.com",
      "Content-Type": "application/x-www-form-urlencoded",
      "Content-Length": 0
    }
  };

  const apiReq = https.request(options, (apiRes) => {
    let rawData = "";

    apiRes.on("data", (chunk) => {
      rawData += chunk;
    });

    apiRes.on("end", () => {
      const trimmed = rawData.trim().toLowerCase();

      // ✅ HTML error detection
      if (
        trimmed.startsWith("<!doctype html") ||
        trimmed.startsWith("<html") ||
        trimmed.includes("<head") ||
        trimmed.includes("<body")
      ) {
        return res.status(502).json({
          success: false,
          message: "RapidAPI returned an HTML page — check subscription or key"
        });
      }

      // ✅ JSON parsing
      try {
        const parsedData = JSON.parse(rawData);

        return res.status(200).json({
          success: true,
          data: parsedData
        });
      } catch (err) {
        console.error("JSON parse error:", err);
        return res.status(500).json({
          success: false,
          message: "Invalid response format from RapidAPI"
        });
      }
    });
  });

  apiReq.on("error", (err) => {
    console.error("HTTPS request error:", err);
    return res.status(500).json({
      success: false,
      message: "Horoscope API request failed",
      error: err.message
    });
  });

  apiReq.end();
};
