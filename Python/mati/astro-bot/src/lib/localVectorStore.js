import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const STORE_DIR = path.join(__dirname, '../store');
const DATA_DIR = path.join(__dirname, '../data');
const VECTORS_FILE = path.join(STORE_DIR, 'vectors.json');

/**
 * Calculate cosine similarity between two vectors
 * @param {number[]} a - First vector
 * @param {number[]} b - Second vector
 * @returns {number} Cosine similarity score
 */
function cosineSimilarity(a, b) {
  if (a.length !== b.length) {
    throw new Error('Vectors must have the same length');
  }

  let dotProduct = 0;
  let normA = 0;
  let normB = 0;

  for (let i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  normA = Math.sqrt(normA);
  normB = Math.sqrt(normB);

  if (normA === 0 || normB === 0) {
    return 0;
  }

  return dotProduct / (normA * normB);
}

/**
 * Normalize a vector to unit length
 * @param {number[]} vector - Vector to normalize
 * @returns {number[]} Normalized vector
 */
function normalize(vector) {
  const norm = Math.sqrt(vector.reduce((sum, val) => sum + val * val, 0));
  if (norm === 0) return vector;
  return vector.map(val => val / norm);
}

/**
 * Initialize the vector store
 * Creates necessary directories and the vectors.json file if they don't exist
 */
export async function initStore() {
  await fs.ensureDir(STORE_DIR);
  await fs.ensureDir(DATA_DIR);

  const exists = await fs.pathExists(VECTORS_FILE);
  if (!exists) {
    await fs.writeJson(VECTORS_FILE, [], { spaces: 2 });
    console.log('[localVectorStore] Initialized vectors.json');
  }
}

/**
 * Read all vectors from the store
 * @returns {Promise<Array>} Array of vector objects
 */
async function readVectors() {
  await initStore();
  return await fs.readJson(VECTORS_FILE);
}

/**
 * Write vectors to the store atomically
 * @param {Array} vectors - Array of vector objects
 */
async function writeVectors(vectors) {
  const tempFile = `${VECTORS_FILE}.tmp`;
  await fs.writeJson(tempFile, vectors, { spaces: 2 });
  await fs.move(tempFile, VECTORS_FILE, { overwrite: true });
}

/**
 * Insert or update a vector in the store
 * @param {Object} vector
 * @param {string} vector.id - Unique identifier
 * @param {string} vector.title - Title of the document
 * @param {string} vector.text - Full text content
 * @param {string} [vector.url] - Optional URL
 * @param {number[]} vector.embedding - Embedding vector
 */
export async function upsertVector({ id, title, text, url, embedding }) {
  const vectors = await readVectors();
  
  const existingIndex = vectors.findIndex(v => v.id === id);
  const vectorData = {
    id,
    title,
    text,
    url: url || null,
    embedding,
    updatedAt: new Date().toISOString(),
  };

  if (existingIndex >= 0) {
    vectors[existingIndex] = vectorData;
    console.log(`[localVectorStore] Updated vector: ${id}`);
  } else {
    vectors.push(vectorData);
    console.log(`[localVectorStore] Added vector: ${id}`);
  }

  await writeVectors(vectors);
}

/**
 * Query vectors by embedding similarity
 * @param {number[]} embedding - Query embedding vector
 * @param {number} [topK=5] - Number of top results to return
 * @returns {Promise<Array>} Top K similar vectors with scores
 */
export async function queryByEmbedding(embedding, topK = 5) {
  const vectors = await readVectors();

  if (vectors.length === 0) {
    return [];
  }

  // Calculate similarity scores
  const results = vectors.map(vector => {
    const score = cosineSimilarity(embedding, vector.embedding);
    const snippet = vector.text.substring(0, 300);
    
    return {
      id: vector.id,
      title: vector.title,
      text: vector.text,
      url: vector.url,
      score,
      snippet,
    };
  });

  // Sort by score descending and return top K
  results.sort((a, b) => b.score - a.score);
  return results.slice(0, topK);
}

/**
 * List all vectors in the store
 * @returns {Promise<Array>} All vectors
 */
export async function listVectors() {
  return await readVectors();
}
