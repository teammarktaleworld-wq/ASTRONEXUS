import app from "./app.js";

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`Horoscope API running on port ${PORT}`);
});
