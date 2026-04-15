import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

export const getBirthChart = async (req, res) => {
  try {
    const { name, dob, tob, place } = req.body;

    if (!name || !dob || !tob || !place) {
      return res.status(400).json({ error: "All fields are required" });
    }

    // Step 1: Get Lat/Long using OpenCage
    const geoUrl = `https://api.opencagedata.com/geocode/v1/json?q=${encodeURIComponent(
      place
    )}&key=${process.env.OPENCAGE_API_KEY}`;

    const geoRes = await axios.get(geoUrl);

    if (!geoRes.data.results || !geoRes.data.results.length) {
      return res.status(400).json({ error: "Invalid place name" });
    }

    const { lat, lng } = geoRes.data.results[0].geometry;

    // Step 2: Prokerala Credentials
    const credentials = `${process.env.PROKERALA_CLIENT_ID}:${process.env.PROKERALA_CLIENT_SECRET}`;
    const encodedAuth = Buffer.from(credentials).toString("base64");

    // Step 3: Call Prokerala Birth Chart API
    const astroRes = await axios.post(
      "https://api.prokerala.com/v2/astrology/birth-chart",
      {
        name,
        date_of_birth: dob,
        time_of_birth: tob,
        latitude: lat,
        longitude: lng,
      },
      {
        headers: {
          Authorization: `Basic ${encodedAuth}`,
          "Content-Type": "application/json",
        },
      }
    );

    return res.json({
      name,
      dob,
      tob,
      place,
      coordinates: { lat, lng },
      chart: astroRes.data,
    });

  } catch (error) {
    console.error("Birth Chart Error:", error.response?.data || error.message);
    return res.status(500).json({
      error: "Birth Chart API error",
      details: error.response?.data || error.message,
    });
  }
};
