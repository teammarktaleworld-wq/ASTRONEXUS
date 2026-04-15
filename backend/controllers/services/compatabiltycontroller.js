const axios = require("axios");

exports.ashtakootScore = async (req, res) => {
  try {
    const { male, female, config } = req.body;

    // Basic validation
    if (!male || !female) {
      return res.status(400).json({
        success: false,
        message: "Male and Female birth details are required",
      });
    }

    const payload = {
      male,
      female,
      config: config || {
        observation_point: "topocentric",
        language: "en",
        ayanamsha: "lahiri",
      },
    };

    const apiKey =
      process.env.FREE_ASTROLOGY_API_KEY ||
      "dL69n3NYvi3wINNqMzqJI31SJokcr30Lc75HEU0g";

    const response = await axios.post(
      "https://json.freeastrologyapi.com/match-making/ashtakoot-score",
      payload,
      {
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey,
        },
        timeout: 10000,
      }
    );

    return res.status(200).json({
      success: true,
      data: response.data,
    });
  } catch (error) {
    // Astrology API responded
    if (error.response) {
      return res.status(error.response.status).json({
        success: false,
        message:
          error.response.data?.message || "Astrology API error",
        details: error.response.data,
      });
    }

    // No response from API
    if (error.request) {
      return res.status(503).json({
        success: false,
        message: "No response from Astrology API",
      });
    }

    // Internal error
    return res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};
