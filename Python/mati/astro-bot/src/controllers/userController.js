import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const USER_DB_FILE = path.join(__dirname, '../store/users.json');

/**
 * Get user profile
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 */
export async function getUserProfile(req, res) {
    try {
        const { userId } = req.params;

        // MOCK DATABASE LOGIC - Replace with MongoDB call later
        // await User.findOne({ userId });

        await fs.ensureFile(USER_DB_FILE);
        const content = await fs.readFile(USER_DB_FILE, 'utf-8');
        const users = content ? JSON.parse(content) : {};

        const user = users[userId];

        if (!user) {
            return res.status(404).json({ ok: false, error: 'User not found' });
        }

        res.json({ ok: true, profile: user });
    } catch (error) {
        res.status(500).json({ ok: false, error: error.message });
    }
}

/**
 * Save/Update user profile
 * @param {Object} req - Express request
 * @param {Object} res - Express response
 */
export async function saveUserProfile(req, res) {
    try {
        const { userId, profile } = req.body;

        if (!userId || !profile) {
            return res.status(400).json({ ok: false, error: 'userId and profile are required' });
        }

        // MOCK DATABASE LOGIC - Replace with MongoDB call later
        // await User.findOneAndUpdate({ userId }, profile, { upsert: true });

        await fs.ensureFile(USER_DB_FILE);
        const content = await fs.readFile(USER_DB_FILE, 'utf-8');
        const users = content ? JSON.parse(content) : {};

        users[userId] = {
            ...users[userId],
            ...profile,
            updatedAt: new Date().toISOString()
        };

        await fs.writeJson(USER_DB_FILE, users, { spaces: 2 });

        res.json({ ok: true, message: 'Profile saved successfully' });
    } catch (error) {
        res.status(500).json({ ok: false, error: error.message });
    }
}
