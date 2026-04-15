import express from 'express';
import { handleChat } from '../controllers/chatController.js';
import { getUserProfile, saveUserProfile } from '../controllers/userController.js';

const router = express.Router();

// Chat Endpoint
// Returns structured analysis for frontend charts
router.post('/chat', handleChat);

// User Profile Endpoints
// Prepared for Database integration (currently using JSON mock)
router.get('/profile/:userId', getUserProfile);
router.post('/profile', saveUserProfile);

export default router;
