import axios from "axios";
import User from "../../models/user/user.js";

const sendToMatiAI = async (payload, retries = 2) => {
  try {
    return await axios.post("https://mati-ai.onrender.com/chat", payload, {
      timeout: 20000
    });
  } catch (err) {
    if (err.response?.status === 429 && retries > 0) {
      console.log("⏳ Rate limited. Retrying in 8 seconds...");
      await new Promise(r => setTimeout(r, 8000));
      return sendToMatiAI(payload, retries - 1);
    }
    throw err;
  }
};

export const askAstrologyChatbot = async (req, res) => {
  try {
    const { session_id, question } = req.body;

    if (!session_id || !question) {
      return res.status(400).json({
        success: false,
        message: "session_id and question required"
      });
    }

    // 🔍 Find logged-in user birth details
    const user = await User.findOne({ sessionId: session_id });

    if (!user || !user.astrologyProfile?.dateOfBirth) {
      return res.status(404).json({
        success: false,
        message: "Birth profile missing. Please complete astrology profile."
      });
    }

    const dob = new Date(user.astrologyProfile.dateOfBirth);
    let [hour, minute] = user.astrologyProfile.timeOfBirth.split(":").map(Number);

    const ampm = hour >= 12 ? "PM" : "AM";
    hour = hour % 12 || 12;

    const payload = {
      session_id,
      birth_input: {
        name: user.name,
        gender: user.astrologyProfile.gender || "male",
        birth_date: {
          year: dob.getFullYear(),
          month: dob.getMonth() + 1,
          day: dob.getDate()
        },
        birth_time: { hour, minute, ampm },
        place_of_birth: user.astrologyProfile.placeOfBirth,
        astrology_type: "vedic",
        ayanamsa: "lahiri"
      },
      question
    };

    const aiResponse = await sendToMatiAI(payload);

    return res.json({
      success: true,
      session_id,
      answer: aiResponse.data.answer || aiResponse.data.response || aiResponse.data
    });

  } catch (error) {
    console.error("Chatbot Error:", error.response?.data || error.message);

    if (error.response?.status === 429) {
      return res.status(429).json({
        success: false,
        message: "Astrology service busy. Please wait a minute."
      });
    }

    res.status(500).json({
      success: false,
      message: "Chatbot service failed",
      error: error.response?.data || error.message
    });
  }
};
