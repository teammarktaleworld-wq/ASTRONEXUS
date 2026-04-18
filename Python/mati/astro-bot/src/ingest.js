import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import { embedText } from './lib/togetherClient.js';
import { initStore, upsertVector } from './lib/localVectorStore.js';

dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DATA_DIR = path.join(__dirname, 'data');
const EMBED_MODEL = process.env.EMBED_MODEL;

/**
 * Create a slug from filename
 * @param {string} filename - Original filename
 * @returns {string} Slugified ID
 */
function createSlug(filename) {
  return filename
    .toLowerCase()
    .replace(/\.[^/.]+$/, '') // Remove extension
    .replace(/[^a-z0-9]+/g, '-') // Replace non-alphanumeric with dashes
    .replace(/^-+|-+$/g, ''); // Remove leading/trailing dashes
}

/**
 * Estimate token count (rough approximation)
 * @param {string} text - Text to estimate
 * @returns {number} Estimated token count
 */
function estimateTokens(text) {
  return Math.ceil(text.split(/\s+/).length * 1.3);
}

/**
 * Process a single file and upsert to vector store
 * @param {string} filepath - Full path to file
 * @param {string} filename - Filename
 * @returns {Promise<Object>} Processing result
 */
async function processFile(filepath, filename) {
  try {
    const text = await fs.readFile(filepath, 'utf-8');
    const id = createSlug(filename);
    const title = filename;
    const tokensEstimate = estimateTokens(text);

    console.log(`Processing: ${filename}...`);

    // Generate embedding
    const embeddingResponse = await embedText(text, { model: EMBED_MODEL });
    
    // Extract embedding array from response
    const embedding = embeddingResponse.data?.[0]?.embedding || embeddingResponse.embedding;
    
    if (!embedding) {
      throw new Error('No embedding returned from API');
    }

    // Upsert to vector store
    await upsertVector({
      id,
      title,
      text,
      url: null,
      embedding,
    });

    return {
      filename,
      id,
      tokensEstimate,
      success: true,
    };
  } catch (error) {
    console.error(`Error processing ${filename}:`, error.message);
    return {
      filename,
      id: createSlug(filename),
      tokensEstimate: 0,
      success: false,
      error: error.message,
    };
  }
}

/**
 * Main ingestion function
 */
async function ingest() {
  console.log('='.repeat(60));
  console.log('Starting data ingestion...');
  console.log('='.repeat(60));

  if (!EMBED_MODEL) {
    console.error('Error: EMBED_MODEL not set in environment variables');
    process.exit(1);
  }

  // Initialize store
  await initStore();

  // Ensure data directory exists
  await fs.ensureDir(DATA_DIR);

  // Read all files from data directory
  const files = await fs.readdir(DATA_DIR);
  
  // Filter out hidden files and directories
  const dataFiles = [];
  for (const file of files) {
    if (file.startsWith('.')) continue;
    
    const filepath = path.join(DATA_DIR, file);
    const stat = await fs.stat(filepath);
    
    if (stat.isFile()) {
      dataFiles.push({ filepath, filename: file });
    }
  }

  if (dataFiles.length === 0) {
    console.log('\nNo files found in src/data directory.');
    console.log('Add .txt or .md files to src/data and run again.');
    return;
  }

  console.log(`\nFound ${dataFiles.length} file(s) to process\n`);

  // Process all files
  const results = [];
  for (const { filepath, filename } of dataFiles) {
    const result = await processFile(filepath, filename);
    results.push(result);
  }

  // Print summary table
  console.log('\n' + '='.repeat(60));
  console.log('Ingestion Summary');
  console.log('='.repeat(60));
  console.log(
    'Filename'.padEnd(30) +
    'ID'.padEnd(20) +
    'Tokens (est)'.padEnd(15)
  );
  console.log('-'.repeat(60));

  for (const result of results) {
    const status = result.success ? '✓' : '✗';
    console.log(
      `${status} ${result.filename.substring(0, 27).padEnd(28)}` +
      result.id.substring(0, 18).padEnd(20) +
      result.tokensEstimate.toString().padEnd(15)
    );
  }

  console.log('-'.repeat(60));
  const successCount = results.filter(r => r.success).length;
  console.log(`Total: ${successCount}/${results.length} files processed successfully`);
  console.log('='.repeat(60));
}

// Run ingestion
ingest().catch(error => {
  console.error('Fatal error during ingestion:', error);
  process.exit(1);
});
