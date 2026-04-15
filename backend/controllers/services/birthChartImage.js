const axios = require("axios");
const fs = require("fs");
const path = require("path");
const { createCanvas } = require("canvas");
const BirthChart = require("../../models/features/birthChartModel");

// 🌟 Planet colors
const planetColors = {
  Sun: "#ff6600",
  Moon: "#666666",
  Mars: "#cc0000",
  Mercury: "#009933",
  Jupiter: "#cc9900",
  Venus: "#ff3399",
  Saturn: "#000099",
  Rahu: "#660099",
  Ketu: "#663300",
  Uranus: "#009999",
  Neptune: "#333399",
  Pluto: "#000000"
};

// 🌟 Planet symbols
const planetSymbols = {
  Sun: "☉",
  Moon: "☽",
  Mars: "♂",
  Mercury: "☿",
  Jupiter: "♃",
  Venus: "♀",
  Saturn: "♄",
  Rahu: "☊",
  Ketu: "☋",
  Uranus: "♅",
  Neptune: "♆",
  Pluto: "♇"
};

// Helper: Generate chart image from chartData
const generateChartImage = async (chartData) => {
  const H = {
    1:{x:450,y:260}, 2:{x:240,y:120}, 3:{x:105,y:250},
    4:{x:240,y:470}, 5:{x:130,y:650}, 6:{x:250,y:768},
    7:{x:450,y:610}, 8:{x:660,y:780}, 9:{x:790,y:650},
    10:{x:630,y:470}, 11:{x:770,y:260}, 12:{x:650,y:150}
  };

  const canvas = createCanvas(900, 900);
  const ctx = canvas.getContext("2d");

  // Background gradient
  const gradient = ctx.createLinearGradient(0, 0, 900, 900);
  gradient.addColorStop(0, "#fdf6e3");
  gradient.addColorStop(1, "#f1e4c6");
  ctx.fillStyle = gradient;
  ctx.fillRect(0, 0, 900, 900);

  // Frame
  ctx.strokeStyle = "#5d4037";
  ctx.lineWidth = 4;
  ctx.strokeRect(50, 50, 800, 800);

  // Diagonals
  ctx.beginPath();
  ctx.moveTo(50, 50); ctx.lineTo(850, 850);
  ctx.moveTo(850, 50); ctx.lineTo(50, 850);
  ctx.stroke();

  // Diamond shape
  ctx.beginPath();
  ctx.moveTo(450, 50);
  ctx.lineTo(850, 450);
  ctx.lineTo(450, 850);
  ctx.lineTo(50, 450);
  ctx.closePath();
  ctx.stroke();

  ctx.textAlign = "center";

  // Draw houses, zodiac, planets
  Object.entries(H).forEach(([num, pos]) => {
    const house = chartData.houses[num];
    if (!house) return;

    let y = pos.y - 40;

    // House label
    ctx.fillStyle = "#3e2723";
    ctx.font = "bold 22px 'Segoe UI'";
    ctx.fillText(`House ${num}`, pos.x, y);

    // Zodiac sign
    y += 26;
    ctx.fillStyle = "#6a1b9a";
    ctx.font = "bold 26px 'Segoe UI'";
    ctx.fillText(house.sign, pos.x, y);

    // Planets
    if (house.planets.length) {
      y += 30;
      house.planets.forEach((p, i) => {
        const symbol = planetSymbols[p] || "•";
        ctx.fillStyle = planetColors[p] || "#000";
        ctx.font = "24px 'Segoe UI Symbol'";
        ctx.fillText(`${symbol} ${p}`, pos.x, y + (i * 22));
      });
    }
  });

  // Ascendant highlight
  const ascHouse = chartData.ascendant?.house;
  if (ascHouse && H[ascHouse]) {
    const { x, y } = H[ascHouse];
    ctx.shadowColor = "rgba(255,0,0,0.6)";
    ctx.shadowBlur = 15;
    ctx.fillStyle = "#d32f2f";
    ctx.font = "bold 20px 'Segoe UI'";
    ctx.fillText("⬆ Ascendant", x, y - 70);
    ctx.shadowBlur = 0;
  }

  // Save image
  const dir = path.join(__dirname, "../charts");
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

  const fileName = `chart_${Date.now()}.png`;
  const filePath = path.join(dir, fileName);
  fs.writeFileSync(filePath, canvas.toBuffer("image/png"));

    console.log("📂 Chart image saved at:", filePath);

  return `/charts/${fileName}`;
};

// Controller: Generate birth chart
exports.generateBirthChart = async (req, res) => {
  try {
    const body = req.body; // may or may not include userId

    // Call Astro Nexus API
    const apiRes = await axios.post(
      "https://astronexus-backend.onrender.com/api/unified/birth-chart",
      body
    );

    const chartData = apiRes.data;

    // Generate chart image
    const chartImage = await generateChartImage(chartData);

    // Extract rashi
    const rashi = chartData.rashi?.toLowerCase() || chartData.ascendant?.sign?.toLowerCase();

    // Save chart (temporary if no userId)
    const saved = await BirthChart.create({
      userId: body.userId || null,
      ...body,
      chartImage,
      chartData,
      rashi,
      isTemporary: !body.userId
    });

    res.status(201).json({
      success: true,
      message: "Birth chart generated",
      data: saved
    });

    console.log("📂 Chart saved at:", filePath);

  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({
      success: false,
      message: "Chart generation failed",
      error: err.message
    });
  }
};