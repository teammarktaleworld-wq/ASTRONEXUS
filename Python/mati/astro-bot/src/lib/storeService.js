import fetch from 'node-fetch';

const DEFAULT_DEV_STORE_BASE_URL = 'http://127.0.0.1:8001';
const DEFAULT_PROD_STORE_BASE_URL = 'https://astronexus-live.onrender.com';
const PRODUCT_FETCH_TIMEOUT_MS = Number(process.env.PRODUCT_FETCH_TIMEOUT_MS || 4500);
const PRODUCT_CACHE_TTL_MS = Number(process.env.PRODUCT_CACHE_TTL_MS || 5 * 60 * 1000);
const MAX_SUGGESTIONS = Number(process.env.PRODUCT_SUGGESTION_LIMIT || 3);
const DEFAULT_CURRENCY = process.env.STORE_CURRENCY || 'INR';

const FALLBACK_PRODUCTS = [
  {
    id: 'fallback-black-tourmaline',
    name: 'Black Tourmaline Pendant',
    description: 'A grounding gemstone traditionally used for protection and energetic stability.',
    price: 499,
    currency: 'INR',
    category: 'Gemstones',
    tags: ['protection', 'negative energy', 'saturn', 'shani', 'grounding'],
    shopUrl: '/shop/products/fallback-black-tourmaline',
  },
  {
    id: 'fallback-rose-quartz',
    name: 'Rose Quartz Love Stone',
    description: 'A gentle crystal associated with emotional healing, harmony, and Venus energy.',
    price: 350,
    currency: 'INR',
    category: 'Crystals',
    tags: ['love', 'relationships', 'venus', 'harmony', 'positivity'],
    shopUrl: '/shop/products/fallback-rose-quartz',
  },
  {
    id: 'fallback-vastu-pyramids',
    name: 'Vastu Pyramids',
    description: 'A common vastu remedy used to support balance and improve energy flow in a space.',
    price: 1200,
    currency: 'INR',
    category: 'Vastu',
    tags: ['vastu', 'home', 'balance', 'space clearing', 'positivity'],
    shopUrl: '/shop/products/fallback-vastu-pyramids',
  },
];

const SEMANTIC_TAG_RULES = [
  { pattern: /\b(saturn|shani)\b/, tags: ['saturn', 'shani', 'discipline', 'protection'] },
  { pattern: /\b(jupiter|guru)\b/, tags: ['jupiter', 'guru', 'wisdom', 'prosperity'] },
  { pattern: /\b(venus|shukra)\b/, tags: ['venus', 'love', 'beauty', 'relationships'] },
  { pattern: /\b(mars|mangal)\b/, tags: ['mars', 'mangal', 'courage', 'energy'] },
  { pattern: /\b(mercury|budh)\b/, tags: ['mercury', 'communication', 'business', 'clarity'] },
  { pattern: /\b(moon|chandra)\b/, tags: ['moon', 'peace', 'mind', 'calm'] },
  { pattern: /\b(sun|surya)\b/, tags: ['sun', 'confidence', 'success', 'leadership'] },
  { pattern: /\b(rahu)\b/, tags: ['rahu', 'protection', 'clarity', 'grounding'] },
  { pattern: /\b(ketu)\b/, tags: ['ketu', 'spiritual', 'meditation', 'cleansing'] },
  { pattern: /\b(protect|protection|shield|grounding|negative)\b/, tags: ['protection', 'negative energy', 'grounding'] },
  { pattern: /\b(love|romance|relationship|marriage|harmony)\b/, tags: ['love', 'relationships', 'harmony'] },
  { pattern: /\b(career|job|business|promotion|success|wealth|money)\b/, tags: ['career', 'business', 'success', 'prosperity'] },
  { pattern: /\b(vastu|home|house|office|property)\b/, tags: ['vastu', 'home', 'balance'] },
  { pattern: /\b(peace|calm|focus|meditation|healing)\b/, tags: ['peace', 'calm', 'meditation', 'healing'] },
  { pattern: /\b(gemstone|crystal|rudraksha)\b/, tags: ['gemstone', 'crystal', 'spiritual remedy'] },
  { pattern: /\b(report|kundli|birth chart|consultation)\b/, tags: ['insight', 'guidance', 'analysis'] },
];

const QUERY_INTENT_RULES = [
  { pattern: /\b(career|job|business|promotion|money|wealth|work)\b/, tags: ['career', 'success', 'business', 'mercury', 'jupiter', 'sun'] },
  { pattern: /\b(love|relationship|marriage|partner|romance)\b/, tags: ['love', 'relationships', 'venus'] },
  { pattern: /\b(home|house|property|vastu|office)\b/, tags: ['vastu', 'home', 'balance'] },
  { pattern: /\b(stress|anxiety|mind|peace|focus|sleep|meditation)\b/, tags: ['peace', 'calm', 'moon', 'meditation'] },
  { pattern: /\b(remedy|gemstone|stone|wear|pooja|ritual)\b/, tags: ['spiritual remedy', 'gemstone', 'pooja'] },
  { pattern: /\b(kundli|birth chart|report|analysis|consultation)\b/, tags: ['analysis', 'insight', 'consultation'] },
  { pattern: /\b(protection|evil eye|negative|dosha)\b/, tags: ['protection', 'negative energy', 'grounding'] },
];

const TYPE_TAGS = {
  gemstone: ['gemstone', 'healing', 'planetary remedy'],
  pooja: ['pooja', 'ritual', 'spiritual support'],
  report: ['report', 'analysis', 'guidance'],
  consultation: ['consultation', 'advisor', 'guidance'],
};

const PRODUCT_ENDPOINTS = ['/user/products', '/user/home-products'];

let productCache = {
  fetchedAt: 0,
  products: [],
};

function stripTrailingSlash(value = '') {
  return String(value).replace(/\/+$/, '');
}

function normalizeText(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function splitKeywords(value) {
  return normalizeText(value)
    .split(' ')
    .map((item) => item.trim())
    .filter((item) => item.length > 2);
}

function uniqueStrings(values = []) {
  return [...new Set(values.filter(Boolean))];
}

function getStoreBaseUrl() {
  const configuredBaseUrl =
    process.env.STORE_API_BASE_URL ||
    process.env.ASTRONEXUS_API_BASE_URL ||
    process.env.BACKEND_BASE_URL;

  if (configuredBaseUrl) {
    return stripTrailingSlash(configuredBaseUrl);
  }

  return process.env.NODE_ENV === 'production'
    ? DEFAULT_PROD_STORE_BASE_URL
    : DEFAULT_DEV_STORE_BASE_URL;
}

function buildSemanticTags(text, astrologyType) {
  const normalized = normalizeText(text);
  const tags = [];

  for (const rule of SEMANTIC_TAG_RULES) {
    if (rule.pattern.test(normalized)) {
      tags.push(...rule.tags);
    }
  }

  if (astrologyType && TYPE_TAGS[astrologyType]) {
    tags.push(...TYPE_TAGS[astrologyType]);
  }

  tags.push(...splitKeywords(normalized));

  return uniqueStrings(tags).slice(0, 12);
}

function normalizeProduct(rawProduct) {
  const id = String(rawProduct?._id || rawProduct?.id || '').trim();
  if (!id) {
    return null;
  }

  const categoryName =
    typeof rawProduct?.category === 'string'
      ? rawProduct.category
      : rawProduct?.category?.name || rawProduct?.astrologyType || 'Spiritual';

  const astrologyType = normalizeText(rawProduct?.astrologyType);
  const combinedText = [
    rawProduct?.name,
    rawProduct?.description,
    categoryName,
    rawProduct?.astrologyType,
  ]
    .filter(Boolean)
    .join(' ');

  const tags = buildSemanticTags(combinedText, astrologyType);

  return {
    id,
    name: String(rawProduct?.name || 'Astro Remedy').trim(),
    description: String(
      rawProduct?.description ||
        `A ${categoryName.toLowerCase()} recommendation selected for astrological support.`
    ).trim(),
    price: Number(rawProduct?.price) || 0,
    currency: String(rawProduct?.currency || DEFAULT_CURRENCY),
    category: String(categoryName).trim(),
    tags,
    shopUrl: `${getStoreBaseUrl()}/user/products/${encodeURIComponent(id)}`,
    imageUrl: Array.isArray(rawProduct?.images) ? rawProduct.images[0] || '' : '',
    astrologyType: astrologyType || 'gemstone',
  };
}

function extractProductsFromPayload(payload) {
  if (Array.isArray(payload)) {
    return payload;
  }

  if (Array.isArray(payload?.products)) {
    return payload.products;
  }

  if (Array.isArray(payload?.data?.products)) {
    return payload.data.products;
  }

  if (Array.isArray(payload?.data)) {
    return payload.data;
  }

  return [];
}

async function fetchJson(url) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), PRODUCT_FETCH_TIMEOUT_MS);

  try {
    const response = await fetch(url, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      throw new Error(`Store API responded with ${response.status}`);
    }

    return await response.json();
  } finally {
    clearTimeout(timeoutId);
  }
}

async function fetchProductsFromBackend() {
  const baseUrl = getStoreBaseUrl();
  const collectedProducts = [];

  for (const endpoint of PRODUCT_ENDPOINTS) {
    try {
      const payload = await fetchJson(`${baseUrl}${endpoint}`);
      const products = extractProductsFromPayload(payload)
        .map(normalizeProduct)
        .filter(Boolean);

      if (products.length > 0) {
        collectedProducts.push(...products);
        if (endpoint === '/user/products') {
          break;
        }
      }
    } catch (error) {
      console.warn(`[storeService] Failed to fetch ${endpoint}:`, error.message);
    }
  }

  const dedupedProducts = uniqueStrings(collectedProducts.map((product) => product.id))
    .map((id) => collectedProducts.find((product) => product.id === id))
    .filter(Boolean);

  if (dedupedProducts.length === 0) {
    throw new Error('No products available from store API');
  }

  productCache = {
    fetchedAt: Date.now(),
    products: dedupedProducts,
  };

  return dedupedProducts;
}

function isCacheFresh() {
  return (
    productCache.products.length > 0 &&
    Date.now() - productCache.fetchedAt < PRODUCT_CACHE_TTL_MS
  );
}

function productContainsSignal(product, signals = []) {
  const productText = normalizeText(
    [product.name, product.description, product.category, product.astrologyType, product.tags.join(' ')].join(' ')
  );

  return signals.some((signal) => {
    const normalizedSignal = normalizeText(signal);
    return normalizedSignal && productText.includes(normalizedSignal);
  });
}

function getNegativePlanets(planetBreakdown = []) {
  return planetBreakdown
    .filter((planet) => normalizeText(planet?.status) === 'negative')
    .map((planet) => normalizeText(planet?.planet))
    .filter(Boolean);
}

function getStrongPositivePlanets(planetBreakdown = []) {
  return planetBreakdown
    .filter(
      (planet) =>
        normalizeText(planet?.status) === 'positive' && Number(planet?.strength || 0) >= 7
    )
    .map((planet) => normalizeText(planet?.planet))
    .filter(Boolean);
}

function getQueryIntentTags(message = '') {
  const normalizedMessage = normalizeText(message);
  const tags = [];

  for (const rule of QUERY_INTENT_RULES) {
    if (rule.pattern.test(normalizedMessage)) {
      tags.push(...rule.tags);
    }
  }

  tags.push(...splitKeywords(normalizedMessage));

  return uniqueStrings(tags);
}

function scoreProduct(product, analysis = {}, message = '') {
  const negativePercentage = Number(analysis?.negativePercentage) || 0;
  const negativePlanets = getNegativePlanets(analysis?.planetBreakdown);
  const positivePlanets = getStrongPositivePlanets(analysis?.planetBreakdown);
  const queryIntentTags = getQueryIntentTags(message);
  const productText = normalizeText(
    [product.name, product.description, product.category, product.astrologyType, product.tags.join(' ')].join(' ')
  );

  let score = 0;

  if (negativePercentage >= 55 && productContainsSignal(product, ['protection', 'negative energy', 'grounding', 'balance'])) {
    score += 20;
  } else if (
    negativePercentage >= 35 &&
    productContainsSignal(product, ['peace', 'positivity', 'balance', 'healing'])
  ) {
    score += 8;
  }

  for (const planet of negativePlanets) {
    if (productContainsSignal(product, [planet])) {
      score += 14;
    }
  }

  for (const planet of positivePlanets) {
    if (productContainsSignal(product, [planet])) {
      score += 6;
    }
  }

  for (const tag of queryIntentTags) {
    if (tag && productText.includes(tag)) {
      score += 4;
    }
  }

  if (/gemstone|stone|wear/.test(normalizeText(message)) && product.astrologyType === 'gemstone') {
    score += 6;
  }

  if (/pooja|ritual|mantra/.test(normalizeText(message)) && product.astrologyType === 'pooja') {
    score += 6;
  }

  if (/report|kundli|chart|analysis/.test(normalizeText(message)) && product.astrologyType === 'report') {
    score += 6;
  }

  if (/consult|consultation|advisor|expert/.test(normalizeText(message)) && product.astrologyType === 'consultation') {
    score += 6;
  }

  if (product.astrologyType === 'gemstone') {
    score += 2;
  }

  return score;
}

function decorateSuggestion(product, score) {
  const reason =
    score >= 24
      ? 'Strong match for the question and current planetary signals.'
      : score >= 12
        ? 'Relevant match based on remedy theme and astrological context.'
        : 'General supportive recommendation from the store catalog.';

  return {
    ...product,
    recommendationReason: reason,
  };
}

export async function getAllProducts({ forceRefresh = false } = {}) {
  if (!forceRefresh && isCacheFresh()) {
    return productCache.products;
  }

  try {
    return await fetchProductsFromBackend();
  } catch (error) {
    console.error('[storeService] Falling back to local products:', error.message);
    return FALLBACK_PRODUCTS;
  }
}

export async function getShopSuggestions(analysis = {}, options = {}) {
  try {
    const message = String(options?.message || '').trim();
    const products = await getAllProducts();

    const rankedProducts = products
      .map((product) => ({
        product,
        score: scoreProduct(product, analysis, message),
      }))
      .sort((left, right) => right.score - left.score || left.product.price - right.product.price);

    const matchedProducts = rankedProducts.filter((entry) => entry.score > 0);
    const selectedProducts =
      matchedProducts.length > 0
        ? matchedProducts.slice(0, MAX_SUGGESTIONS)
        : rankedProducts.slice(0, Math.min(MAX_SUGGESTIONS, products.length));

    return selectedProducts.map(({ product, score }) => decorateSuggestion(product, score));
  } catch (error) {
    console.error('[storeService] Error getting suggestions:', error.message);
    return FALLBACK_PRODUCTS.slice(0, Math.min(MAX_SUGGESTIONS, FALLBACK_PRODUCTS.length));
  }
}
