import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PROJECT_ROOT = path.resolve(__dirname, '..', '..');
const ENV_FILE_PATH = path.join(PROJECT_ROOT, '.env');

let loaded = false;

export function ensureEnvLoaded() {
  if (loaded) {
    return ENV_FILE_PATH;
  }

  dotenv.config({ path: ENV_FILE_PATH });
  loaded = true;
  return ENV_FILE_PATH;
}

ensureEnvLoaded();

export { ENV_FILE_PATH, PROJECT_ROOT };
