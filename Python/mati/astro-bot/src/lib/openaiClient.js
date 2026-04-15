import fetch from 'node-fetch';

// Auto-detect API provider based on key prefix
function getAPIConfig() {
  const API_KEY = process.env.OPENAI_API_KEY || process.env.GROQ_API_KEY;

  if (!API_KEY) {
    throw new Error('No API key found. Set OPENAI_API_KEY or GROQ_API_KEY in environment variables');
  }

  // Groq keys start with 'gsk_'
  if (API_KEY.startsWith('gsk_')) {
    return {
      baseURL: 'https://api.groq.com/openai/v1',
      apiKey: API_KEY,
      provider: 'groq',
      defaultModel: 'llama-3.3-70b-versatile' // Current Groq model (updated Feb 2026)
    };
  }

  // OpenAI keys start with 'sk-'
  return {
    baseURL: 'https://api.openai.com/v1',
    apiKey: API_KEY,
    provider: 'openai',
    defaultModel: 'gpt-4o-mini'
  };
}

/**
 * Call AI model for chat completions (supports OpenAI and Groq)
 * @param {Object} options
 * @param {string} options.model - Model identifier (auto-selected if not provided)
 * @param {Array} options.messages - Array of message objects with role and content
 * @param {number} [options.temperature=0.3] - Temperature for sampling
 * @param {number} [options.max_tokens=512] - Maximum tokens to generate
 * @returns {Promise<Object>} Parsed response from AI API
 */
export async function callModel({ model, messages, temperature = 0.3, max_tokens = 512 }) {
  const config = getAPIConfig();
  const isDev = process.env.NODE_ENV !== 'production';

  // Use provided model or default for the provider
  const selectedModel = model || config.defaultModel;

  const url = `${config.baseURL}/chat/completions`;

  const body = {
    model: selectedModel,
    messages,
    temperature,
    max_tokens,
  };

  if (isDev) {
    console.debug(`[${config.provider}Client] Using provider: ${config.provider}`);
    console.debug(`[${config.provider}Client] Calling model: ${selectedModel}`);
    console.debug(`[${config.provider}Client] Messages:`, JSON.stringify(messages, null, 2));
  }

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${config.apiKey}`,
      },
      body: JSON.stringify(body),
    });

    if (!response.ok) {
      const errorText = await response.text();
      if (isDev) {
        console.debug(`[${config.provider}Client] Error response:`, errorText);
      }
      throw new Error(`${config.provider.toUpperCase()} API error (${response.status}): ${errorText}`);
    }

    const data = await response.json();

    if (isDev) {
      console.debug(`[${config.provider}Client] Response received:`, JSON.stringify(data, null, 2));
    }

    return data;
  } catch (error) {
    console.error(`[${config.provider}Client] Request failed:`, error.message);
    throw error;
  }
}

/**
 * Extract text from API response
 * @param {Object} response - API response
 * @returns {string} Extracted text
 */
export function extractResponseText(response) {
  if (response.choices?.[0]?.message?.content) {
    return response.choices[0].message.content;
  }

  throw new Error('Unable to extract text from API response');
}

// Note: Embeddings functionality temporarily disabled
// Will be re-enabled when switching back to Together AI or using OpenAI embeddings
/**
 * Generate embeddings for text (TEMPORARILY DISABLED)
 * @param {string} text - Text to embed
 * @param {Object} options
 * @returns {Promise<Object>} Placeholder response
 */
export async function embedText(text, options = {}) {
  console.warn('[Client] Embeddings are temporarily disabled');
  // Return a placeholder to prevent errors
  return {
    data: [{
      embedding: null
    }]
  };
}
