import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { callModel, extractResponseText } from '../lib/openaiClient.js';
import { buildSystemPrompt } from '../lib/retrieval.js';
// import { retrieveContextForQuery } from '../lib/retrieval.js'; // Temporarily disabled

import { getShopSuggestions } from '../lib/storeService.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const HISTORY_FILE = path.join(__dirname, '../store/history.json');

/**
 * Load session history from file
 * @returns {Promise<Object>} Session history object
 */
async function loadHistory() {
  try {
    await fs.ensureFile(HISTORY_FILE);
    const content = await fs.readFile(HISTORY_FILE, 'utf-8');
    return content ? JSON.parse(content) : {};
  } catch (error) {
    return {};
  }
}

/**
 * Save session history to file
 * @param {Object} history - Session history object
 */
async function saveHistory(history) {
  const tempFile = `${HISTORY_FILE}.tmp`;
  await fs.writeJson(tempFile, history, { spaces: 2 });
  await fs.move(tempFile, HISTORY_FILE, { overwrite: true });
}

// extractResponseText is now imported from openaiClient.js

/**
 * Determine dynamic UI metadata (labels, colors, verdict) based on user query and score
 * @param {string} message - User's question
 * @param {number} score - Overall decision score
 * @returns {Object} UI metadata
 */
function getDynamicUIContext(message, score) {
  const query = message.toLowerCase();

  // Default Labels
  let labels = { positive: 'Positive', negative: 'Negative' };
  let type = 'general';

  // 1. Keyword based labeling
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

  // 2. Verdict logic (Going "overboard" with user friendliness)
  let verdict = 'Neutral';
  let color = '#888888'; // Grey

  if (score >= 80) {
    verdict = 'Highly Favorable';
    color = '#22C55E'; // Green
  } else if (score >= 60) {
    verdict = 'Moderately Good';
    color = '#84CC16'; // Lime
  } else if (score >= 40) {
    verdict = 'Proceed with Caution';
    color = '#EAB308'; // Yellow
  } else {
    verdict = 'Avoid / Postpone';
    color = '#EF4444'; // Red
  }

  // 3. Recommended Action
  let action = 'Seek more details';
  if (score > 70) action = 'Proceed with confidence';
  if (score < 40) action = 'Perform remedies before starting';

  return {
    labels,
    type,
    verdict,
    color,
    action,
    summary: `${verdict}: ${score}% alignment with cosmic energies.`
  };
}

/**
 * Handle chat request
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 */
export async function handleChat(req, res) {
  try {
    const { userId, sessionId, message, userProfile, max_context_docs } = req.body;

    // Validate input
    if (!message || typeof message !== 'string') {
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

    // Prepare context with User Profile if provided
    let fullUserMessage = message;
    if (userProfile) {
      const profileStr = Object.entries(userProfile)
        .map(([key, val]) => `${key}: ${val}`)
        .join(', ');
      fullUserMessage = `[User Profile Data: ${profileStr}]\n\nUser Question: ${message}`;
    } else {
      // Mock data suggestion for testing if no profile is provided
      fullUserMessage = `[Note: No real birth data provided. Use general astronomical transits for today.]\n\nUser Question: ${message}`;
    }

    // Build messages array for AI model
    const systemPrompt = buildSystemPrompt();

    const messages = [
      {
        role: 'system',
        content: systemPrompt
      },
      {
        role: 'user',
        content: fullUserMessage
      }
    ];

    // Call AI model (auto-detects Groq or OpenAI based on API key)
    const modelResponse = await callModel({
      messages,
      temperature: 0.3,
      max_tokens: 1024, // Increased tokens for detailed analysis
    });

    // Extract response text
    const responseText = extractResponseText(modelResponse);

    // Parse JSON response from model
    let parsedResponse;
    try {
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        parsedResponse = JSON.parse(jsonMatch[0]);
      } else {
        parsedResponse = JSON.parse(responseText);
      }
    } catch (error) {
      parsedResponse = {
        answer: responseText,
        analysis: {
          decisionScore: 50,
          positivePercentage: 50,
          negativePercentage: 50,
          planetBreakdown: []
        },
        citations: [],
        raw: 'Response was not in expected JSON format',
      };
    }

    // Load and update session history
    const history = await loadHistory();
    if (!history[sessionId]) {
      history[sessionId] = [];
    }

    history[sessionId].push(
      {
        role: 'user',
        content: message,
        timestamp: new Date().toISOString(),
      },
      {
        role: 'assistant',
        content: parsedResponse.answer,
        timestamp: new Date().toISOString(),
      }
    );

    await saveHistory(history);

    // Sanitize Analysis Data for Frontend (Prevent Null pointer errors)
    const sanitizedAnalysis = {
      decisionScore: Number(parsedResponse.analysis?.decisionScore) || 0,
      positivePercentage: Number(parsedResponse.analysis?.positivePercentage) || 0,
      negativePercentage: Number(parsedResponse.analysis?.negativePercentage) || 0,
      planetBreakdown: Array.isArray(parsedResponse.analysis?.planetBreakdown)
        ? parsedResponse.analysis.planetBreakdown.map(p => ({
          planet: String(p.planet || 'Unknown'),
          status: String(p.status || 'neutral'),
          strength: Number(p.strength) || 5,
          reason: String(p.reason || 'No details available.')
        }))
        : []
    };

    // Ensure they add up to 100 or at least are not both null
    if (sanitizedAnalysis.positivePercentage === 0 && sanitizedAnalysis.negativePercentage === 0) {
      sanitizedAnalysis.positivePercentage = sanitizedAnalysis.decisionScore || 50;
      sanitizedAnalysis.negativePercentage = 100 - sanitizedAnalysis.positivePercentage;
    }

    // Get Dynamic UI Context (Labels, Verdicts, Colors)
    const uiMetadata = getDynamicUIContext(message, sanitizedAnalysis.decisionScore);

    // Get Shop Suggestions based on analysis
    const shopSuggestions = await getShopSuggestions(sanitizedAnalysis);

    // Minimize raw model response
    const rawModelResponse = {
      model: modelResponse.model,
      usage: modelResponse.usage,
    };

    res.json({
      ok: true,
      answer: parsedResponse.answer,
      analysis: sanitizedAnalysis,
      uiMetadata, // New dynamic labels and metadata
      shopSuggestions,
      citations: parsedResponse.citations || [],
      rawModelResponse,
    });






  } catch (error) {
    console.error('[chatController] Error:', error);
    res.status(500).json({
      ok: false,
      error: error.message || 'Internal server error',
    });
  }
}
