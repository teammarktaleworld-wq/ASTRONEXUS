import axios from "axios";

/**
 * Controller: Generate horoscope chart SVG
 * POST /api/horoscope/chart
 */
export const getHoroscopeChartSvg = async (req, res) => {
  try {
    const {
      year,
      month,
      date,
      hours,
      minutes,
      seconds = 0, // default to 0
      latitude,
      longitude,
      timezone,
    } = req.body;

    // Basic validation
    if (
      year === undefined ||
      month === undefined ||
      date === undefined ||
      hours === undefined ||
      minutes === undefined ||
      latitude === undefined ||
      longitude === undefined ||
      timezone === undefined
    ) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    // Call Free Astrology API
    const response = await axios.post(
      "https://json.freeastrologyapi.com/horoscope-chart-svg-code",
      {
        year,
        month,
        date,
        hours,
        minutes,
        seconds,
        latitude,
        longitude,
        timezone,
        config: {
          observation_point: "topocentric",
          ayanamsha: "lahiri",
        },
      },
      {
        headers: {
          "Content-Type": "application/json",
          "x-api-key": process.env.FREE_ASTROLOGY_API_KEY,
        },
        timeout: 15000,
      }
    );

    // Return SVG string to client
    res.status(200).json({
      success: true,
      svg: response.data,
    });
  } catch (error) {
    console.error("Horoscope API error:", error.response?.data || error.message);
    res.status(500).json({
      success: false,
      message: "Failed to generate horoscope chart",
    });
  }
};
