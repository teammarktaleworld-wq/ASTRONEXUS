import axios from "axios";

const SCRAPED_BASE_URL =
  "https://horoscope-app-api.vercel.app/api/v1/get-horoscope";

const OHMANDA_BASE_URL = "https://ohmanda.com/api/horoscope";

// --- helpers ---
const normalizeSign = (sign) => String(sign).toLowerCase();
const normalizeType = (type) => String(type).toLowerCase();
const normalizeDay = (day) => String(day).toUpperCase();

// Remove empty / null fields
const removeEmptyFields = (obj) => {
  return Object.fromEntries(
    Object.entries(obj).filter(
      ([_, value]) => value !== null && value !== undefined && value !== ""
    )
  );
};

// ✅ IST date generator (AUTHORITATIVE)
const getISTDateLabel = () => {
  const now = new Date();

  const istDate = new Date(
    now.toLocaleString("en-US", { timeZone: "Asia/Kolkata" })
  );

  return istDate.toLocaleDateString("en-IN", {
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
};

// Normalize Ohmanda daily response (IST aligned)
const normalizeOhmandaDaily = (raw) => {
  return {
    horoscope_data: raw?.horoscope || "",
    date: getISTDateLabel(), // 🔒 IST date, NOT provider date
  };
};

export const getHoroscope = async (req, res) => {
  console.log("🔥 Horoscope route HIT", req.query);

  try {
    let { sign, type = "daily", day = "TODAY" } = req.query;

    if (!sign) {
      return res.status(400).json({
        success: false,
        message: "Zodiac sign is required",
      });
    }

    // Normalize inputs
    sign = normalizeSign(sign);
    type = normalizeType(type);
    day = normalizeDay(day);

    let responseData;

    // =========================
    // DAILY → OHMANDA (TEXT) + IST DATE
    // =========================
    if (type === "daily") {
      const ohmandaUrl = `${OHMANDA_BASE_URL}/${sign}`;
      console.log("🌐 Fetching DAILY (Ohmanda):", ohmandaUrl);

      const resp = await axios.get(ohmandaUrl, {
        headers: {
          Accept: "application/json",
          "User-Agent": "AstroNexus/1.0",
        },
        timeout: 15000,
      });

      if (!resp.data || !resp.data.horoscope) {
        throw new Error("Invalid response from Ohmanda");
      }

      responseData = removeEmptyFields(
        normalizeOhmandaDaily(resp.data)
      );
    }

    // =========================
    // WEEKLY / MONTHLY → EXISTING API (UNCHANGED)
    // =========================
    else if (type === "weekly" || type === "monthly") {
      const url =
        type === "weekly"
          ? `${SCRAPED_BASE_URL}/weekly`
          : `${SCRAPED_BASE_URL}/monthly`;

      console.log(`🌐 Fetching ${type.toUpperCase()} (Scraped):`, url);

      const resp = await axios.get(url, {
        params: { sign },
        headers: {
          Accept: "application/json",
          "User-Agent": "AstroNexus/1.0",
        },
        timeout: 15000,
      });

      if (!resp.data || !resp.data.data) {
        throw new Error("Invalid response from horoscope provider");
      }

      responseData = resp.data.data;
    } else {
      return res.status(400).json({
        success: false,
        message: "Invalid horoscope type",
      });
    }

    // Unified response
    return res.json({
      success: true,
      type,
      sign,
      data: responseData,
    });
  } catch (error) {
    console.error("❌ Horoscope API FULL ERROR:", {
      message: error.message,
      code: error.code,
      hostname: error.hostname,
      response: error.response?.data,
    });

    if (error.code === "ENOTFOUND") {
      return res.status(503).json({
        success: false,
        message:
          "Horoscope service unreachable from server network. Try again later.",
      });
    }

    return res.status(500).json({
      success: false,
      message: "Failed to fetch horoscope",
    });
  }
};
