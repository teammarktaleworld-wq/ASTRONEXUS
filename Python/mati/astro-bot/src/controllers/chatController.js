import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { callModel, extractResponseText } from '../lib/openaiClient.js';
import { buildSystemPrompt } from '../lib/retrieval.js';
import { getShopSuggestions } from '../lib/storeService.js';
import { getNutritionGuidance } from '../lib/nutritionService.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const HISTORY_FILE = path.join(__dirname, '../store/history.json');
const SESSION_HISTORY_LIMIT = Number(process.env.SESSION_HISTORY_LIMIT || 24);
const MODEL_CONTEXT_HISTORY_LIMIT = Number(process.env.MODEL_CONTEXT_HISTORY_LIMIT || 6);
const APP_TIMEZONE = process.env.APP_TIMEZONE || 'Asia/Kolkata';

const DECISION_QUERY_REGEX =
  /\b(should|can|will|good time|right time|best time|worth it|recommend|favorable|beneficial|safe to)\b/i;
const PRODUCT_QUERY_REGEX =
  /\b(remedy|gemstone|stone|wear|buy|product|consultation|pooja|ritual|vastu|dosha|negative energy)\b/i;
const DETAILED_QUERY_REGEX =
  /\b(explain|why|how|detail|detailed|full|deep|prediction|forecast|reading|analysis|this month|monthly|this year|yearly|career|relationship|marriage|finance|health|future)\b/i;
const QUICK_QUERY_REGEX = /^(is|can|should|will|when|what|who|where|does|do|am|are)\b/i;
const ASTRONOMY_QUERY_REGEX =
  /\b(astronomy|astrophysics|cosmology|black hole|galaxy|nebula|telescope|nasa|exoplanet|milky way|solar system|light year|orbit)\b/i;
const PREDICTION_QUERY_REGEX =
  /\b(prediction|forecast|future|this month|monthly|this week|weekly|this year|yearly|timing|period|phase)\b/i;
const EXACT_TIMING_QUERY_REGEX =
  /\b(exact date|exact day|specific date|specific day|date|timing|muhurat|muhurta|auspicious|suitable date|best date|marry|marriage|wedding|shaadi|shadi|vivah)\b/i;
const REPORT_QUERY_REGEX =
  /\b(report|pdf|download|full report|detailed report|kundli report|marriage report|relationship report)\b/i;
const REPORT_ONLY_QUERY_REGEX =
  /^\s*(report|pdf|download pdf|full report|detailed report)\s*$/i;

async function loadHistory() {
  try {
    await fs.ensureFile(HISTORY_FILE);
    const content = await fs.readFile(HISTORY_FILE, 'utf-8');
    return content ? JSON.parse(content) : {};
  } catch (error) {
    return {};
  }
}

async function saveHistory(history) {
  const tempFile = `${HISTORY_FILE}.tmp`;
  await fs.writeJson(tempFile, history, { spaces: 2 });
  await fs.move(tempFile, HISTORY_FILE, { overwrite: true });
}

function normalizeText(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9\s]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function getCurrentDateContext() {
  const isoFormatter = new Intl.DateTimeFormat('en-US', {
    timeZone: APP_TIMEZONE,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  const parts = isoFormatter.formatToParts(new Date());
  const year = parts.find((part) => part.type === 'year')?.value || '0000';
  const month = parts.find((part) => part.type === 'month')?.value || '01';
  const day = parts.find((part) => part.type === 'day')?.value || '01';

  return {
    readable: new Intl.DateTimeFormat('en-US', {
      timeZone: APP_TIMEZONE,
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    }).format(new Date()),
    iso: `${year}-${month}-${day}`,
  };
}

function capitalize(value) {
  const text = String(value || '').trim();
  return text ? `${text[0].toUpperCase()}${text.slice(1)}` : '';
}

function countWords(text) {
  return String(text || '')
    .trim()
    .split(/\s+/)
    .filter(Boolean).length;
}

function clampPercentage(value) {
  const numericValue = Number(value);
  if (!Number.isFinite(numericValue)) {
    return 0;
  }

  return Math.min(100, Math.max(0, numericValue));
}

function isDecisionStyleQuery(message = '') {
  return DECISION_QUERY_REGEX.test(String(message || '').trim());
}

function detectTopic(normalizedMessage = '') {
  if (/\bcareer|job|work|office|promotion|business|profession\b/.test(normalizedMessage)) return 'career';
  if (/\blove|relationship|marriage|partner|romance\b/.test(normalizedMessage)) return 'love';
  if (/\bhealth|wellness|sleep|stress|diet|food|nutrition|healing\b/.test(normalizedMessage)) return 'health';
  if (/\bmoney|finance|wealth|income|investment\b/.test(normalizedMessage)) return 'finance';
  if (/\bhome|house|property|vastu|family\b/.test(normalizedMessage)) return 'home';
  if (/\beducation|study|exam|student|learning\b/.test(normalizedMessage)) return 'education';
  if (/\bspiritual|meditation|mantra|sadhana|chakra\b/.test(normalizedMessage)) return 'spiritual';
  return 'general';
}

function detectTimeframe(normalizedMessage = '') {
  if (/\btoday|this day\b/.test(normalizedMessage)) return 'today';
  if (/\bthis week|weekly\b/.test(normalizedMessage)) return 'this week';
  if (/\bthis month|monthly\b/.test(normalizedMessage)) return 'this month';
  if (/\bthis year|yearly\b/.test(normalizedMessage)) return 'this year';
  if (/\bnext month\b/.test(normalizedMessage)) return 'next month';
  return 'general';
}

function getQuestionProfile(message = '') {
  const trimmedMessage = String(message || '').trim();
  const normalizedMessage = normalizeText(trimmedMessage);
  const wordCount = countWords(trimmedMessage);
  const domain = ASTRONOMY_QUERY_REGEX.test(normalizedMessage) ? 'astronomy' : 'astrology';
  const topic = detectTopic(normalizedMessage);
  const timeframe = detectTimeframe(normalizedMessage);
  const wantsPrediction =
    PREDICTION_QUERY_REGEX.test(normalizedMessage) || isDecisionStyleQuery(trimmedMessage);
  const wantsReport = REPORT_QUERY_REGEX.test(normalizedMessage);
  const wantsExactTiming =
    EXACT_TIMING_QUERY_REGEX.test(normalizedMessage) ||
    (topic === 'love' &&
      /\bwhen\b/.test(normalizedMessage) &&
      /\b(marriage|marry|wedding|partner)\b/.test(normalizedMessage));
  const answerMode = wantsReport
    ? 'report'
    : DETAILED_QUERY_REGEX.test(normalizedMessage) || wordCount > 14
      ? 'detailed'
      : QUICK_QUERY_REGEX.test(trimmedMessage) && wordCount <= 10
        ? 'concise'
        : 'standard';
  const currentDate = getCurrentDateContext();

  return {
    rawMessage: trimmedMessage,
    normalizedMessage,
    answerMode,
    domain,
    topic,
    timeframe,
    wantsPrediction,
    wantsReport,
    reportOnly: REPORT_ONLY_QUERY_REGEX.test(trimmedMessage),
    wantsExactTiming,
    explicitRemedyInterest: PRODUCT_QUERY_REGEX.test(normalizedMessage),
    includeNutrition: domain !== 'astronomy',
    maxTokens:
      answerMode === 'report'
        ? 1600
        : answerMode === 'detailed'
          ? 1200
          : answerMode === 'concise'
            ? 650
            : 900,
    sentenceGuide:
      answerMode === 'report'
        ? '8 to 14 sentences with clear report-style sections'
        : answerMode === 'detailed'
        ? '6 to 9 sentences'
        : answerMode === 'concise'
          ? '2 to 4 sentences'
          : '4 to 6 sentences',
    currentDate,
  };
}

function shouldOfferProductSuggestions(queryProfile, analysis = {}) {
  return (
    queryProfile.explicitRemedyInterest ||
    (queryProfile.domain !== 'astronomy' &&
      Number(analysis?.negativePercentage || 0) >= 75 &&
      queryProfile.wantsPrediction)
  );
}

function getDynamicUIContext(message, score, options = {}) {
  const query = String(message || '').toLowerCase();
  const hasBirthData = Boolean(options?.hasBirthData);
  const decisionMode = isDecisionStyleQuery(message);
  const queryProfile = options?.queryProfile || {};

  let labels = { positive: 'Support', negative: 'Caution' };
  let type = decisionMode ? 'decision' : 'insight';

  if (/\bshould\b/i.test(query)) {
    labels = { positive: 'Should', negative: 'Should Not' };
    type = 'advice';
  } else if (/\bcan\b/i.test(query)) {
    labels = { positive: 'Can', negative: 'Cannot' };
    type = 'possibility';
  } else if (/\bwill\b/i.test(query)) {
    labels = { positive: 'Likely', negative: 'Unlikely' };
    type = 'prediction';
  } else if (/\b(is it|are they) good\b/i.test(query) || /\bbeneficial\b/i.test(query)) {
    labels = { positive: 'Beneficial', negative: 'Harmful' };
    type = 'quality';
  }

  if (!decisionMode) {
    const timeframeSummary =
      queryProfile.timeframe && queryProfile.timeframe !== 'general'
        ? ` for ${queryProfile.timeframe}`
        : '';
    const reportSummary = queryProfile.wantsReport
      ? ' A structured PDF-style report is available for this reading.'
      : '';

    return {
      labels,
      type,
      verdict: 'Astro Insight',
      color: '#2563EB',
      action: queryProfile.wantsReport
        ? 'Download the structured PDF report for a full written reading'
        : hasBirthData
          ? 'Ask for timing, remedies, or food guidance for a deeper reading'
          : 'Share birth details for more precise timing and personalization',
      summary: hasBirthData
        ? `This interpretation${timeframeSummary} is based on the strongest planetary themes in your question and profile.${reportSummary}`
        : `This is a general reading${timeframeSummary} based on broad planetary themes because no birth details were shared.${reportSummary}`,
    };
  }

  let verdict = 'Neutral';
  let color = '#888888';

  if (score >= 80) {
    verdict = 'Highly Favorable';
    color = '#22C55E';
  } else if (score >= 60) {
    verdict = 'Moderately Good';
    color = '#84CC16';
  } else if (score >= 40) {
    verdict = 'Proceed with Caution';
    color = '#EAB308';
  } else {
    verdict = 'Avoid / Postpone';
    color = '#EF4444';
  }

  let action = hasBirthData
    ? 'Proceed thoughtfully and keep timing disciplined'
    : 'Use this as general guidance and share birth details for accurate timing';
  if (score > 70) action = 'Proceed with confidence but stay consistent';
  if (score < 40) action = 'Slow down, strengthen timing, and avoid rushed moves';

  return {
    labels,
    type,
    verdict,
    color,
    action,
    summary: `${verdict}: ${score}% alignment with the current astrological signals.`,
  };
}

function formatProfileValue(value) {
  if (value === null || value === undefined) {
    return '';
  }

  if (Array.isArray(value)) {
    return value.map((item) => String(item).trim()).filter(Boolean).join(', ');
  }

  if (typeof value === 'object') {
    return JSON.stringify(value);
  }

  return String(value).trim();
}

function hasCompleteBirthData(userProfile) {
  if (!userProfile || typeof userProfile !== 'object') {
    return false;
  }

  return ['birthDate', 'birthTime', 'birthPlace'].every((key) =>
    Boolean(formatProfileValue(userProfile[key]))
  );
}

function buildUserPrompt(message, userProfile, queryProfile) {
  const profileEntries =
    userProfile && typeof userProfile === 'object'
      ? Object.entries(userProfile)
          .map(([key, value]) => {
            const formattedValue = formatProfileValue(value);
            return formattedValue ? `- ${key}: ${formattedValue}` : '';
          })
          .filter(Boolean)
      : [];

  const sections = [];

  if (profileEntries.length > 0) {
    sections.push(`Known profile details:\n${profileEntries.join('\n')}`);
  } else {
    sections.push(
      'Profile note: No birth details were shared, so make the reading general and mention that birth data would improve accuracy.'
    );
  }

  sections.push(
    `Question profile:\n- Domain: ${queryProfile.domain}\n- Topic: ${queryProfile.topic}\n- Timeframe: ${queryProfile.timeframe}\n- Response mode: ${queryProfile.answerMode}\n- Target length: ${queryProfile.sentenceGuide}`
  );

  sections.push(
    `Date context:\n- Today in ${APP_TIMEZONE}: ${queryProfile.currentDate?.readable || ''}\n- ISO date: ${queryProfile.currentDate?.iso || ''}`
  );

  if (queryProfile.wantsExactTiming) {
    sections.push(
      profileEntries.length > 0
        ? 'Timing guidance:\n- The user wants exact timing if responsibly possible.\n- Provide up to 3 future calendar dates in YYYY-MM-DD format when the chart support is clear.\n- If certainty is limited, say so and prefer a narrow date window over false certainty.'
        : 'Timing guidance:\n- Do not invent exact dates because birth details are missing.\n- State clearly that exact marriage or event dates need birth date, birth time, and birth place.\n- Keep the answer helpful and practical even when exact timing is not possible.'
    );
  }

  if (queryProfile.wantsReport) {
    sections.push(
      'Report guidance:\n- Shape the answer like a polished professional report summary.\n- Include enough detail to support a clean PDF export.\n- If the user simply asked for "report", rely on the current conversation context and produce a complete summary.'
    );
  }

  sections.push(
    'Answer goals:\n- Give the direct answer first.\n- Keep the tone warm, practical, and specific.\n- If this is a prediction, mention the strongest support, main caution, and practical next step.\n- Avoid vague filler or extreme advice.\n- Mention remedies only when they genuinely help.\n- Do not mention products or shopping.'
  );

  sections.push(`User question: ${String(message || '').trim()}`);

  return sections.join('\n\n');
}

function buildConversationMessages(sessionHistory = []) {
  return sessionHistory
    .filter(
      (entry) =>
        ['user', 'assistant'].includes(entry?.role) &&
        typeof entry?.content === 'string' &&
        entry.content.trim()
    )
    .slice(-MODEL_CONTEXT_HISTORY_LIMIT)
    .map((entry) => ({
      role: entry.role,
      content: entry.content.trim(),
    }));
}

function tryParseJson(candidate) {
  try {
    return JSON.parse(candidate);
  } catch (error) {
    return null;
  }
}

function extractStructuredResponse(responseText) {
  const cleanedText = String(responseText || '')
    .replace(/```json/gi, '')
    .replace(/```/g, '')
    .trim();

  const directParse = tryParseJson(cleanedText);
  if (directParse) {
    return directParse;
  }

  for (
    let start = cleanedText.indexOf('{');
    start !== -1;
    start = cleanedText.indexOf('{', start + 1)
  ) {
    let depth = 0;
    let inString = false;
    let escaped = false;

    for (let index = start; index < cleanedText.length; index += 1) {
      const character = cleanedText[index];

      if (escaped) {
        escaped = false;
        continue;
      }

      if (character === '\\' && inString) {
        escaped = true;
        continue;
      }

      if (character === '"') {
        inString = !inString;
        continue;
      }

      if (inString) {
        continue;
      }

      if (character === '{') depth += 1;
      if (character === '}') depth -= 1;

      if (depth === 0) {
        const candidate = cleanedText.slice(start, index + 1);
        const parsedCandidate = tryParseJson(candidate);
        if (parsedCandidate) {
          return parsedCandidate;
        }
        break;
      }
    }
  }

  return {
    answer: cleanedText,
    analysis: {
      decisionScore: 50,
      positivePercentage: 50,
      negativePercentage: 50,
      planetBreakdown: [],
    },
    citations: [],
    raw: 'Response was not in expected JSON format',
  };
}

function sanitizeCitations(citations) {
  if (!Array.isArray(citations)) {
    return [];
  }

  return citations
    .map((citation) => {
      if (typeof citation === 'string') {
        return {
          title: citation.trim(),
          url: '',
        };
      }

      if (!citation || typeof citation !== 'object') {
        return null;
      }

      return {
        title: String(citation.title || citation.name || 'Reference').trim(),
        url: String(citation.url || citation.source || '').trim(),
      };
    })
    .filter((citation) => citation && (citation.title || citation.url))
    .slice(0, 5);
}

function normalizePlanetStatus(status) {
  return String(status || '').toLowerCase() === 'positive' ? 'positive' : 'negative';
}

function sanitizeAnalysis(rawAnalysis = {}) {
  let decisionScore = clampPercentage(rawAnalysis?.decisionScore);
  let positivePercentage = clampPercentage(rawAnalysis?.positivePercentage);
  let negativePercentage = clampPercentage(rawAnalysis?.negativePercentage);

  if (positivePercentage === 0 && negativePercentage === 0) {
    positivePercentage = decisionScore || 50;
    negativePercentage = 100 - positivePercentage;
  } else {
    const total = positivePercentage + negativePercentage;
    if (total > 0 && total !== 100) {
      positivePercentage = Math.round((positivePercentage / total) * 100);
      negativePercentage = 100 - positivePercentage;
    }
  }

  if (decisionScore === 0 && positivePercentage > 0) {
    decisionScore = positivePercentage;
  }

  const planetBreakdown = Array.isArray(rawAnalysis?.planetBreakdown)
    ? rawAnalysis.planetBreakdown
        .map((planet) => ({
          planet: String(planet?.planet || 'Unknown').trim(),
          status: normalizePlanetStatus(planet?.status),
          strength: Math.min(10, Math.max(1, Number(planet?.strength) || 5)),
          reason: String(planet?.reason || 'No details available.').trim(),
        }))
        .slice(0, 6)
    : [];

  return {
    decisionScore,
    positivePercentage,
    negativePercentage,
    planetBreakdown,
  };
}

function isValidIsoDate(value) {
  const trimmedValue = String(value || '').trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(trimmedValue)) {
    return false;
  }

  return Number.isFinite(Date.parse(`${trimmedValue}T00:00:00Z`));
}

function normalizeConfidence(value) {
  const normalizedValue = String(value || '').trim().toLowerCase();
  if (['high', 'medium', 'low'].includes(normalizedValue)) {
    return normalizedValue;
  }

  return 'medium';
}

function sanitizeDateEntries(rawEntries = [], currentDateIso = '') {
  if (!Array.isArray(rawEntries)) {
    return [];
  }

  return rawEntries
    .map((entry) => {
      if (typeof entry === 'string') {
        const date = entry.trim();
        if (!isValidIsoDate(date)) {
          return null;
        }

        return {
          date,
          label: 'Suggested date',
          confidence: 'medium',
          reason: '',
        };
      }

      if (!entry || typeof entry !== 'object') {
        return null;
      }

      const date = String(entry.date || entry.day || '').trim();
      if (!isValidIsoDate(date)) {
        return null;
      }

      return {
        date,
        label: String(entry.label || entry.title || 'Suggested date').trim(),
        confidence: normalizeConfidence(entry.confidence),
        reason: String(entry.reason || entry.note || '').trim(),
      };
    })
    .filter(Boolean)
    .filter((entry) => !currentDateIso || entry.date >= currentDateIso)
    .slice(0, 4);
}

function sanitizeTiming(rawTiming = {}, queryProfile = {}, options = {}) {
  const hasBirthData = Boolean(options?.hasBirthData);
  const currentDateIso = String(options?.currentDateIso || '').trim();
  const favorableDates = sanitizeDateEntries(rawTiming?.favorableDates, currentDateIso);
  const avoidDates = sanitizeDateEntries(rawTiming?.avoidDates, currentDateIso);
  const requested =
    queryProfile.wantsExactTiming ||
    favorableDates.length > 0 ||
    avoidDates.length > 0 ||
    Boolean(rawTiming?.note);
  const requiresBirthData = !hasBirthData && queryProfile.wantsExactTiming;
  const exactDatePossible =
    hasBirthData && Boolean(rawTiming?.exactDatePossible) && favorableDates.length > 0;
  const note =
    String(rawTiming?.note || '').trim() ||
    (requiresBirthData
      ? 'Exact dates need birth date, birth time, and birth place for a proper Vedic timing reading.'
      : requested && favorableDates.length === 0
        ? 'Treat this as timing guidance, not a guaranteed fixed outcome.'
        : '');

  if (!requested && !note) {
    return null;
  }

  return {
    requested,
    exactDatePossible,
    requiresBirthData,
    favorableDates,
    avoidDates,
    note,
  };
}

function buildAnalysisExpansion(analysis = {}, queryProfile = {}) {
  const positivePlanet = (analysis.planetBreakdown || []).find(
    (planet) => planet.status === 'positive'
  );
  const negativePlanet = (analysis.planetBreakdown || []).find(
    (planet) => planet.status === 'negative'
  );
  const sentences = [];

  if (queryProfile.timeframe && queryProfile.timeframe !== 'general') {
    sentences.push(
      `For ${queryProfile.timeframe}, take this as a trend reading rather than a fixed outcome.`
    );
  }

  if (positivePlanet) {
    sentences.push(
      `${capitalize(positivePlanet.planet)} is the clearest support right now, so lean into ${positivePlanet.reason.toLowerCase()}.`
    );
  }

  if (negativePlanet) {
    sentences.push(
      `${capitalize(negativePlanet.planet)} asks for extra care, so avoid rushed decisions and keep your routine disciplined.`
    );
  }

  return sentences.join(' ');
}

function normalizeAnswer(answer, options = {}) {
  const hasBirthData = Boolean(options?.hasBirthData);
  const queryProfile = options?.queryProfile || {};
  const analysis = options?.analysis || {};
  const timing = options?.timing || null;
  const cleanedAnswer = String(answer || '')
    .replace(/\r\n/g, '\n')
    .replace(/\n{3,}/g, '\n\n')
    .trim();

  if (!cleanedAnswer) {
    return hasBirthData
      ? 'Based on the details you shared, the chart points to a mixed but readable trend. Ask a more specific timing or remedy question if you want a sharper answer.'
      : 'This is a general reading because no birth details were provided. Share your birth date, time, and place for a more personalized answer.';
  }

  let normalizedAnswer = cleanedAnswer;
  const wordCount = countWords(normalizedAnswer);

  if (queryProfile.answerMode === 'detailed' && wordCount < 45) {
    normalizedAnswer = `${normalizedAnswer} ${buildAnalysisExpansion(analysis, queryProfile)}`.trim();
  }

  if (queryProfile.answerMode === 'standard' && wordCount < 26) {
    normalizedAnswer = `${normalizedAnswer} ${buildAnalysisExpansion(analysis, queryProfile)}`.trim();
  }

  if (queryProfile.wantsExactTiming && !hasBirthData) {
    const needsBirthDataNote =
      ' Exact marriage dates require birth date, birth time, and birth place.';
    normalizedAnswer = /birth (date|details|time|place)/i.test(normalizedAnswer)
      ? normalizedAnswer
      : `${normalizedAnswer}${needsBirthDataNote}`.trim();
  }

  if (
    queryProfile.wantsExactTiming &&
    timing?.favorableDates?.length > 0 &&
    !timing.favorableDates.some((item) => normalizedAnswer.includes(item.date))
  ) {
    const directDates = timing.favorableDates
      .slice(0, 3)
      .map((item) => item.date)
      .join(', ');
    normalizedAnswer = `${normalizedAnswer} Stronger dates to consider: ${directDates}.`.trim();
  }

  return normalizedAnswer;
}

function slugify(value = '') {
  const slug = String(value || '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 72);

  return slug || 'astro-report';
}

function createReportTitle(queryProfile = {}, subject = '') {
  const normalizedSubject = normalizeText(subject);

  if (/\b(marriage|marry|wedding|shaadi|shadi|vivah)\b/.test(normalizedSubject)) {
    return 'Marriage Timing Report';
  }

  switch (queryProfile.topic) {
    case 'career':
      return 'Career Guidance Report';
    case 'love':
      return queryProfile.wantsExactTiming
        ? 'Relationship Timing Report'
        : 'Relationship Guidance Report';
    case 'health':
      return 'Wellness Guidance Report';
    case 'finance':
      return 'Finance Guidance Report';
    case 'spiritual':
      return 'Spiritual Guidance Report';
    default:
      return 'Astrology Guidance Report';
  }
}

function createTimingSectionText(timing = null) {
  if (!timing) {
    return '';
  }

  const sections = [];

  if (timing.favorableDates.length > 0) {
    sections.push(
      `Favorable dates: ${timing.favorableDates
        .map((item) =>
          `${item.date}${item.reason ? ` (${item.reason})` : ''}`
        )
        .join('; ')}.`
    );
  }

  if (timing.avoidDates.length > 0) {
    sections.push(
      `Dates to handle carefully: ${timing.avoidDates
        .map((item) =>
          `${item.date}${item.reason ? ` (${item.reason})` : ''}`
        )
        .join('; ')}.`
    );
  }

  if (timing.note) {
    sections.push(timing.note);
  }

  return sections.join(' ');
}

function createPlanetSectionText(analysis = {}) {
  if (!Array.isArray(analysis?.planetBreakdown) || analysis.planetBreakdown.length === 0) {
    return '';
  }

  return analysis.planetBreakdown
    .slice(0, 5)
    .map(
      (planet) =>
        `${capitalize(planet.planet)}: ${planet.status === 'positive' ? 'supportive' : 'cautious'} at strength ${planet.strength}/10. ${planet.reason}`
    )
    .join(' ');
}

function createProfileSectionText(userProfile, hasBirthData) {
  if (!hasBirthData || !userProfile || typeof userProfile !== 'object') {
    return 'This is a general report because complete birth details were not available. Share birth date, time, and place for exact timing.';
  }

  const lines = Object.entries(userProfile)
    .map(([key, value]) => {
      const formattedValue = formatProfileValue(value);
      return formattedValue ? `${capitalize(key)}: ${formattedValue}` : '';
    })
    .filter(Boolean);

  return lines.join('. ');
}

function appendUniqueSections(targetSections = [], incomingSections = []) {
  const seen = new Set(
    targetSections.map((section) => normalizeText(section.heading || ''))
  );

  for (const rawSection of incomingSections) {
    if (!rawSection || typeof rawSection !== 'object') {
      continue;
    }

    const heading = String(rawSection.heading || rawSection.title || '').trim();
    const content = String(rawSection.content || rawSection.body || '').trim();
    const normalizedHeading = normalizeText(heading);

    if (!heading || !content || seen.has(normalizedHeading)) {
      continue;
    }

    seen.add(normalizedHeading);
    targetSections.push({ heading, content });
  }

  return targetSections;
}

function buildReportPayload(options = {}) {
  const queryProfile = options?.queryProfile || {};

  if (!queryProfile.wantsReport) {
    return null;
  }

  const rawReport = options?.rawReport || {};
  const answer = String(options?.answer || '').trim();
  const uiMetadata = options?.uiMetadata || null;
  const nutritionGuidance = options?.nutritionGuidance || null;
  const timing = options?.timing || null;
  const rawNotes = String(options?.rawNotes || '').trim();
  const subject = String(options?.subject || queryProfile.rawMessage || '').trim();
  const hasBirthData = Boolean(options?.hasBirthData);
  const generatedDate = queryProfile.currentDate?.iso || getCurrentDateContext().iso;
  const title = String(rawReport?.title || '').trim() || createReportTitle(queryProfile, subject);
  const summary = String(rawReport?.summary || '').trim() || answer;
  const sections = [];

  if (summary) {
    sections.push({ heading: 'Overview', content: summary });
  }

  const timingSection = createTimingSectionText(timing);
  if (timingSection) {
    sections.push({ heading: 'Timing', content: timingSection });
  }

  const planetSection = createPlanetSectionText(options?.analysis);
  if (planetSection) {
    sections.push({ heading: 'Planetary Highlights', content: planetSection });
  }

  if (uiMetadata) {
    const guidanceText = [uiMetadata.summary, uiMetadata.action].filter(Boolean).join(' ');
    if (guidanceText) {
      sections.push({ heading: 'Practical Guidance', content: guidanceText });
    }
  }

  if (nutritionGuidance) {
    const nutritionText = [
      nutritionGuidance.focus ? `Focus: ${nutritionGuidance.focus}.` : '',
      Array.isArray(nutritionGuidance.foodsToFavor) &&
      nutritionGuidance.foodsToFavor.length > 0
        ? `Foods to favor: ${nutritionGuidance.foodsToFavor.join(', ')}.`
        : '',
      Array.isArray(nutritionGuidance.foodsToLimit) &&
      nutritionGuidance.foodsToLimit.length > 0
        ? `Foods to limit: ${nutritionGuidance.foodsToLimit.join(', ')}.`
        : '',
      nutritionGuidance.mealSuggestion ? `Meal suggestion: ${nutritionGuidance.mealSuggestion}.` : '',
      nutritionGuidance.timingTip ? `Timing tip: ${nutritionGuidance.timingTip}.` : '',
    ]
      .filter(Boolean)
      .join(' ');

    if (nutritionText) {
      sections.push({ heading: 'Lifestyle Support', content: nutritionText });
    }
  }

  const profileSection = createProfileSectionText(options?.userProfile, hasBirthData);
  if (profileSection) {
    sections.push({ heading: 'Profile Basis', content: profileSection });
  }

  appendUniqueSections(sections, rawReport?.sections);

  sections.push({
    heading: 'Disclaimer',
    content:
      rawNotes ||
      (hasBirthData
        ? 'Astrological timing is interpretive guidance and not a guarantee of events.'
        : 'This report is general guidance only. Exact dates require birth date, birth time, and birth place.'),
  });

  return {
    requested: true,
    title,
    subtitle: hasBirthData
      ? 'Structured Vedic reading for PDF download'
      : 'General Vedic reading for PDF download',
    summary,
    generatedOn: queryProfile.currentDate?.readable || '',
    fileName: `${slugify(title)}-${generatedDate}.pdf`,
    sections: sections.slice(0, 8),
  };
}

function resolveReportSubject(message, sessionHistory = []) {
  const trimmedMessage = String(message || '').trim();
  if (!REPORT_ONLY_QUERY_REGEX.test(trimmedMessage)) {
    return trimmedMessage;
  }

  const earlierUserPrompt = [...sessionHistory]
    .reverse()
    .find(
      (entry) =>
        entry?.role === 'user' &&
        typeof entry?.content === 'string' &&
        entry.content.trim() &&
        !REPORT_ONLY_QUERY_REGEX.test(entry.content.trim())
    );

  return earlierUserPrompt?.content?.trim() || trimmedMessage;
}

export async function handleChat(req, res) {
  try {
    const { sessionId, message, userProfile } = req.body || {};
    const trimmedMessage = String(message || '').trim();

    if (!trimmedMessage) {
      return res.status(400).json({
        ok: false,
        error: 'Message is required and must be a string',
      });
    }

    if (!sessionId) {
      return res.status(400).json({
        ok: false,
        error: 'sessionId is required',
      });
    }

    const queryProfile = getQuestionProfile(trimmedMessage);
    const hasBirthData = hasCompleteBirthData(userProfile);

    const history = await loadHistory();
    const sessionHistory = Array.isArray(history[sessionId]) ? history[sessionId] : [];
    const reportSubject = resolveReportSubject(trimmedMessage, sessionHistory);

    const messages = [
      {
        role: 'system',
        content: buildSystemPrompt({
          hasBirthData,
          answerMode: queryProfile.answerMode,
          topic: queryProfile.topic,
          timeframe: queryProfile.timeframe,
          domain: queryProfile.domain,
          wantsExactTiming: queryProfile.wantsExactTiming,
          wantsReport: queryProfile.wantsReport,
          currentDate: queryProfile.currentDate,
        }),
      },
      ...buildConversationMessages(sessionHistory),
      {
        role: 'user',
        content: buildUserPrompt(
          trimmedMessage,
          hasBirthData ? userProfile : null,
          queryProfile
        ),
      },
    ];

    const modelResponse = await callModel({
      messages,
      temperature: queryProfile.answerMode === 'concise' ? 0.25 : 0.35,
      max_tokens: queryProfile.maxTokens,
    });

    const responseText = extractResponseText(modelResponse);
    const parsedResponse = extractStructuredResponse(responseText);
    const sanitizedAnalysis = sanitizeAnalysis(parsedResponse?.analysis);
    const timing = sanitizeTiming(parsedResponse?.timing, queryProfile, {
      hasBirthData,
      currentDateIso: queryProfile.currentDate?.iso,
    });
    const answer = normalizeAnswer(parsedResponse?.answer, {
      hasBirthData,
      queryProfile,
      analysis: sanitizedAnalysis,
      timing,
    });
    const uiMetadata = getDynamicUIContext(trimmedMessage, sanitizedAnalysis.decisionScore, {
      hasBirthData,
      queryProfile,
    });
    const nutritionGuidance = queryProfile.includeNutrition
      ? getNutritionGuidance({
          analysis: sanitizedAnalysis,
          message: trimmedMessage,
          queryProfile,
        })
      : null;
    const shopSuggestions = shouldOfferProductSuggestions(queryProfile, sanitizedAnalysis)
      ? await getShopSuggestions(sanitizedAnalysis, { message: trimmedMessage, userProfile })
      : [];
    const report = buildReportPayload({
      queryProfile,
      subject: reportSubject,
      answer,
      analysis: sanitizedAnalysis,
      uiMetadata,
      nutritionGuidance,
      timing,
      rawReport: parsedResponse?.report,
      rawNotes: parsedResponse?.raw,
      hasBirthData,
      userProfile,
    });

    history[sessionId] = [
      ...sessionHistory,
      {
        role: 'user',
        content: trimmedMessage,
        timestamp: new Date().toISOString(),
      },
      {
        role: 'assistant',
        content: answer,
        timestamp: new Date().toISOString(),
      },
    ].slice(-SESSION_HISTORY_LIMIT);

    await saveHistory(history);

    res.json({
      ok: true,
      answer,
      analysis: sanitizedAnalysis,
      timing,
      report,
      uiMetadata,
      nutritionGuidance,
      shopSuggestions,
      citations: sanitizeCitations(parsedResponse?.citations),
      rawModelResponse: {
        model: modelResponse.model,
        usage: modelResponse.usage,
      },
    });
  } catch (error) {
    console.error('[chatController] Error:', error);
    const statusCode =
      Number.isInteger(error?.statusCode) && error.statusCode >= 400 && error.statusCode < 600
        ? error.statusCode
        : 500;

    res.status(statusCode).json({
      ok: false,
      error: error.userMessage || error.message || 'Internal server error',
    });
  }
}
