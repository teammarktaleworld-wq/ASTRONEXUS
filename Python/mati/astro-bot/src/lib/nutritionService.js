const PLANET_NUTRITION_RULES = {
  sun: {
    focus: 'vitality and steady confidence',
    favor: ['warm grains', 'citrus fruits', 'pumpkin', 'light ginger tea'],
    limit: ['heavy fried lunches', 'overeating in the afternoon', 'too much refined sugar'],
  },
  moon: {
    focus: 'emotional balance and hydration',
    favor: ['coconut water', 'cucumber', 'rice', 'melon', 'warm milk or plant milk'],
    limit: ['excess salt', 'late heavy desserts', 'skipping meals'],
  },
  mars: {
    focus: 'directed energy without restlessness',
    favor: ['beetroot', 'red lentils', 'pomegranate', 'lightly spiced soups'],
    limit: ['too much chilli', 'fried spicy food', 'excess caffeine'],
  },
  mercury: {
    focus: 'clarity, focus, and communication',
    favor: ['moong dal', 'leafy greens', 'fresh herbs', 'amla or pear'],
    limit: ['chaotic snacking', 'excess sugar', 'too many packaged snacks'],
  },
  jupiter: {
    focus: 'growth, optimism, and nourishment',
    favor: ['turmeric', 'chickpeas', 'yellow lentils', 'ghee in moderation'],
    limit: ['very heavy sweets', 'overindulgence', 'rich oversized dinners'],
  },
  venus: {
    focus: 'harmony and gentle nourishment',
    favor: ['sweet fruits', 'dates', 'cardamom', 'rose or saffron infused drinks'],
    limit: ['too much sugar', 'rich creamy late-night meals', 'constant desserts'],
  },
  saturn: {
    focus: 'grounding, stamina, and discipline',
    favor: ['millets', 'sesame', 'root vegetables', 'black gram', 'simple soups'],
    limit: ['skipping meals', 'dry processed foods', 'too much fast food'],
  },
  rahu: {
    focus: 'calming overstimulation and cravings',
    favor: ['plain khichdi', 'grounding grains', 'fennel', 'cooling herbs'],
    limit: ['energy drinks', 'ultra-processed snacks', 'very smoky foods'],
  },
  ketu: {
    focus: 'lightness with stability',
    favor: ['simple soups', 'steamed vegetables', 'ginger tea', 'moong'],
    limit: ['erratic fasting', 'overly dry meals', 'irregular meal timing'],
  },
};

const TOPIC_MEAL_TEMPLATES = {
  career:
    'A grounding lunch with millets or rice, dal, sauteed greens, and a sesame-based side can support focus and steadiness.',
  love:
    'A balanced meal with sweet fruit, warm grains, and a calming herbal drink can support softness and emotional harmony.',
  health:
    'Prefer a simple warm plate with seasonal vegetables, easy-to-digest protein, and steady hydration instead of extreme diets.',
  finance:
    'Choose simple disciplined meals, such as dal, grains, and vegetables, so your energy stays even and decisions stay practical.',
  home:
    'Warm home-cooked meals with grounding grains and vegetables are more supportive than rushed or highly processed food right now.',
  education:
    'A light but nourishing meal with moong dal, greens, fruit, and enough water can help concentration and mental clarity.',
  spiritual:
    'Simple sattvic-style meals with khichdi, seasonal vegetables, and herbal tea can support calm focus and reflection.',
  general:
    'Keep meals simple, warm, and regular, with a balance of grains, lentils, vegetables, and enough hydration.',
};

function normalizeText(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function uniqueItems(items = []) {
  return [...new Set(items.filter(Boolean))];
}

function capitalize(value) {
  const text = String(value || '').trim();
  return text ? `${text[0].toUpperCase()}${text.slice(1)}` : '';
}

function inferTopic(message = '') {
  const query = normalizeText(message);

  if (/\bcareer|job|work|office|promotion|profession|business\b/.test(query)) return 'career';
  if (/\blove|relationship|marriage|partner|romance\b/.test(query)) return 'love';
  if (/\bhealth|healing|stress|sleep|wellness|energy\b/.test(query)) return 'health';
  if (/\bmoney|finance|wealth|income|investment\b/.test(query)) return 'finance';
  if (/\bhome|house|property|vastu|family\b/.test(query)) return 'home';
  if (/\bstudy|exam|education|learning|student\b/.test(query)) return 'education';
  if (/\bspiritual|meditation|sadhana|mantra|chakra\b/.test(query)) return 'spiritual';

  return 'general';
}

function getSortedPlanets(analysis = {}) {
  const planets = Array.isArray(analysis?.planetBreakdown) ? analysis.planetBreakdown : [];

  return planets
    .map((planet) => ({
      name: normalizeText(planet?.planet),
      status: normalizeText(planet?.status),
      strength: Number(planet?.strength) || 0,
    }))
    .filter((planet) => planet.name)
    .sort((left, right) => right.strength - left.strength);
}

function getFocusSummary(topic, leadingPlanets) {
  const firstRule = leadingPlanets
    .map((planet) => PLANET_NUTRITION_RULES[planet])
    .find(Boolean);

  if (firstRule) {
    return firstRule.focus;
  }

  switch (topic) {
    case 'career':
      return 'steady focus, grounded energy, and consistent routines';
    case 'love':
      return 'emotional warmth, softness, and balanced nourishment';
    case 'health':
      return 'calm digestion, hydration, and stable energy';
    case 'finance':
      return 'discipline, clarity, and steady energy';
    case 'education':
      return 'clarity, memory support, and calm concentration';
    default:
      return 'balanced energy and steady nourishment';
  }
}

export function getNutritionGuidance({ analysis = {}, message = '', queryProfile = {} } = {}) {
  const topic = queryProfile.topic || inferTopic(message);
  const sortedPlanets = getSortedPlanets(analysis);
  const leadingPlanets = uniqueItems(
    sortedPlanets.slice(0, 2).map((planet) => planet.name)
  );
  const negativePlanets = uniqueItems(
    sortedPlanets
      .filter((planet) => planet.status === 'negative')
      .slice(0, 2)
      .map((planet) => planet.name)
  );

  const foodsToFavor = uniqueItems(
    leadingPlanets.flatMap((planet) => PLANET_NUTRITION_RULES[planet]?.favor || [])
  ).slice(0, 5);

  const foodsToLimit = uniqueItems(
    negativePlanets.flatMap((planet) => PLANET_NUTRITION_RULES[planet]?.limit || [])
  ).slice(0, 5);

  const primaryFocus = getFocusSummary(topic, leadingPlanets);
  const mealSuggestion = TOPIC_MEAL_TEMPLATES[topic] || TOPIC_MEAL_TEMPLATES.general;
  const timingTip =
    queryProfile.timeframe === 'this month'
      ? 'This month, regular meal timing and warm freshly cooked food will support better stability than erratic eating.'
      : 'Keep meal timing regular and avoid skipping breakfast or lunch when your schedule becomes busy.';

  return {
    focus: primaryFocus,
    foodsToFavor:
      foodsToFavor.length > 0
        ? foodsToFavor
        : ['warm cooked grains', 'dal', 'seasonal vegetables', 'fresh fruit'],
    foodsToLimit:
      foodsToLimit.length > 0
        ? foodsToLimit
        : ['highly processed snacks', 'very heavy late-night meals'],
    mealSuggestion,
    timingTip,
    dominantPlanets: leadingPlanets.map(capitalize),
    note: 'General nutritional astrology guidance only, not medical advice.',
  };
}
