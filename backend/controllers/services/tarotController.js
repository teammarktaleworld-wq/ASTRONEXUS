const axios = require('axios');

const BASE_URL = 'https://tarotapi.dev/api/v1';

exports.getRandomCards = async (req, res) => {
  try {
    let n = parseInt(req.query.n) || 1; // number of cards
    if (n < 1 || n > 78) n = 1;        // limit to 1-78 cards

    const response = await axios.get(`${BASE_URL}/cards/random?n=${n}`);
    const cards = response.data.cards;

    res.status(200).json({
      nhits: response.data.nhits,
      cards: cards.map(card => ({
        name: card.name,
        value: card.value,
        type: card.type,
        meaning_up: card.meaning_up,
        meaning_rev: card.meaning_rev,
        desc: card.desc,
      })),
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ error: 'Failed to fetch tarot cards' });
  }
};
