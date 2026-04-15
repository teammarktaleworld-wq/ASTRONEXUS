import axios from "axios";

const HTTP_TIMEOUT_MS = Number(process.env.UNIFIED_PROXY_TIMEOUT_MS || 45000);
const client = axios.create({
  timeout: HTTP_TIMEOUT_MS,
});

const VALID_SIGNS = new Set([
  "aries",
  "taurus",
  "gemini",
  "cancer",
  "leo",
  "virgo",
  "libra",
  "scorpio",
  "sagittarius",
  "capricorn",
  "aquarius",
  "pisces",
]);

const VALID_HOROSCOPE_TYPES = new Set(["daily", "weekly", "monthly"]);
const VALID_HOROSCOPE_DAYS = new Set(["TODAY", "TOMORROW", "YESTERDAY"]);

const stripTrailingSlash = (value) => String(value).replace(/\/+$/, "");

const getServiceUrls = () => ({
  birthChart: stripTrailingSlash(
    process.env.BIRTH_CHART_SERVICE_URL || "http://127.0.0.1:8010"
  ),
  horoscope: stripTrailingSlash(
    process.env.HOROSCOPE_SERVICE_URL || "http://127.0.0.1:4000"
  ),
  mati: stripTrailingSlash(process.env.MATI_CHAT_SERVICE_URL || "http://127.0.0.1:3000"),
});

const normalizeAxiosError = (service, error) => {
  if (error.response) {
    return {
      service,
      statusCode: error.response.status || 502,
      message: `Upstream ${service} service returned an error`,
      details: error.response.data,
    };
  }

  if (error.request) {
    return {
      service,
      statusCode: 503,
      message: `Upstream ${service} service is unreachable`,
      details: error.message,
    };
  }

  return {
    service,
    statusCode: 500,
    message: `Unexpected ${service} wrapper failure`,
    details: error.message,
  };
};

const callBirthChartService = async (payload) => {
  const services = getServiceUrls();
  const response = await client.post(`${services.birthChart}/api/v1/chart`, payload);
  return response.data;
};

const callHoroscopeService = async (query) => {
  const services = getServiceUrls();
  const response = await client.get(`${services.horoscope}/api/horoscope`, {
    params: query,
  });
  return response.data;
};

const callMatiService = async (payload) => {
  const services = getServiceUrls();
  const response = await client.post(`${services.mati}/api/chat`, payload);
  return response.data;
};

export const unifiedHealth = async (req, res) => {
  const services = getServiceUrls();

  const checks = await Promise.allSettled([
    client.get(`${services.birthChart}/openapi.json`),
    client.get(`${services.horoscope}/`),
    client.get(`${services.mati}/health`),
  ]);

  const [birthChartCheck, horoscopeCheck, matiCheck] = checks;
  const toHealth = (check) => (check.status === "fulfilled" ? "up" : "down");

  const report = {
    birthChart: {
      url: services.birthChart,
      status: toHealth(birthChartCheck),
    },
    horoscope: {
      url: services.horoscope,
      status: toHealth(horoscopeCheck),
    },
    mati: {
      url: services.mati,
      status: toHealth(matiCheck),
    },
  };

  const allUp = Object.values(report).every((item) => item.status === "up");
  return res.status(allUp ? 200 : 503).json({
    success: allUp,
    services: report,
  });
};

export const proxyBirthChart = async (req, res) => {
  try {
    const chartData = await callBirthChartService(req.body);
    return res.status(200).json({
      success: true,
      service: "birth_chart",
      data: chartData,
    });
  } catch (error) {
    const normalized = normalizeAxiosError("birth_chart", error);
    return res.status(normalized.statusCode).json({
      success: false,
      ...normalized,
    });
  }
};

export const proxyHoroscope = async (req, res) => {
  try {
    const sign = String(req.query.sign || "").toLowerCase().trim();
    const type = String(req.query.type || "daily").toLowerCase().trim();
    const day = String(req.query.day || "TODAY").toUpperCase().trim();

    if (!sign || !VALID_SIGNS.has(sign)) {
      return res.status(400).json({
        success: false,
        message: "Valid zodiac sign is required",
      });
    }

    if (!VALID_HOROSCOPE_TYPES.has(type)) {
      return res.status(400).json({
        success: false,
        message: "Invalid horoscope type. Use daily, weekly, or monthly",
      });
    }

    if (type === "daily" && !VALID_HOROSCOPE_DAYS.has(day)) {
      return res.status(400).json({
        success: false,
        message: "Invalid day. Use TODAY, TOMORROW, or YESTERDAY",
      });
    }

    const query = type === "daily" ? { sign, type, day } : { sign, type };
    const data = await callHoroscopeService(query);

    return res.status(200).json({
      success: true,
      service: "horoscope",
      data,
    });
  } catch (error) {
    const normalized = normalizeAxiosError("horoscope", error);
    return res.status(normalized.statusCode).json({
      success: false,
      ...normalized,
    });
  }
};

export const proxyMatiChat = async (req, res) => {
  try {
    const { sessionId, message } = req.body || {};
    if (!sessionId || !message) {
      return res.status(400).json({
        success: false,
        message: "sessionId and message are required",
      });
    }

    const data = await callMatiService(req.body);
    return res.status(200).json({
      success: true,
      service: "mati_chatbot",
      data,
    });
  } catch (error) {
    const normalized = normalizeAxiosError("mati_chatbot", error);
    return res.status(normalized.statusCode).json({
      success: false,
      ...normalized,
    });
  }
};

export const aggregateUnified = async (req, res) => {
  const { birthChart, horoscope, matiChat } = req.body || {};

  const serviceCalls = [];
  if (birthChart) {
    serviceCalls.push({
      key: "birthChart",
      execute: () => callBirthChartService(birthChart),
    });
  }
  if (horoscope) {
    serviceCalls.push({
      key: "horoscope",
      execute: () => callHoroscopeService(horoscope),
    });
  }
  if (matiChat) {
    serviceCalls.push({
      key: "matiChat",
      execute: () => callMatiService(matiChat),
    });
  }

  if (serviceCalls.length === 0) {
    return res.status(400).json({
      success: false,
      message: "Provide at least one payload: birthChart, horoscope, or matiChat",
    });
  }

  const settled = await Promise.allSettled(serviceCalls.map((entry) => entry.execute()));

  const services = {};
  let allSucceeded = true;

  for (let index = 0; index < settled.length; index += 1) {
    const result = settled[index];
    const key = serviceCalls[index].key;

    if (result.status === "fulfilled") {
      services[key] = {
        success: true,
        data: result.value,
      };
      continue;
    }

    allSucceeded = false;
    services[key] = {
      success: false,
      error: normalizeAxiosError(key, result.reason),
    };
  }

  return res.status(allSucceeded ? 200 : 207).json({
    success: allSucceeded,
    services,
  });
};
