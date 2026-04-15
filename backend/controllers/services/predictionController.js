import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

export const getGeneralPrediction = async (req, res) => {
  try {
    const { name, dob, tob, place } = req.body;

    const credentials = `${process.env.CLIENT_ID}:${process.env.CLIENT_SECRET}`;
    const encodedAuth = Buffer.from(credentials).toString("base64");

    const response = await axios.post(
      "https://api.prokerala.com/v2/astrology/general/prediction",
      {
        name: name,
        date_of_birth: dob,
        time_of_birth: tob,
        place_of_birth: place,
      },
      {
        headers: {
          Authorization: `Basic ${encodedAuth}`,
          "Content-Type": "application/json",
        },
      }
    );

    return res.json(response.data);

  } catch (error) {
    console.log("Prokerala Error:", error.response?.data || error.message);

    return res.status(500).json({
      error: "Prokerala API error",
      details: error.response?.data,
    });
  }
};
