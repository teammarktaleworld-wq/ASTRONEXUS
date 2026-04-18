# AstroBot Backend API

A Node.js backend for an AI-powered chatbot that answers questions about **Indian astrology** (horoscopes, vastu, gemstones) and **scientific astronomy** (planets, stars, galaxies).

## Quick Start

```bash
# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.example .env
# Add your OpenAI API key to .env

# 3. Start server
npm start

# 4. Test (in another terminal)
npm run test:local
```

Server runs on `http://localhost:3000`

## API Endpoints

### Health Check
```
GET /health
```
Returns server status and uptime.

### Chat
```
POST /api/chat
```

**Request:**
```json
{
  "sessionId": "unique-session-id",
  "message": "What is the role of Saturn in astrology and astronomy?"
}
```

**Response:**
```json
{
  "ok": true,
  "answer": "Saturn plays dual roles... [3-6 sentence answer]",
  "citations": [],
  "sources": [],
  "rawModelResponse": {
    "model": "gpt-4o-mini",
    "usage": { "total_tokens": 245 }
  }
}
```

## Environment Variables

```env
OPENAI_API_KEY=sk-your_key_here
OPENAI_MODEL=gpt-4o-mini
PORT=3000
```

## Example Questions

**Indian Astrology:**
- "What does it mean if my Moon is in Scorpio?"
- "Give vastu tips for a north-facing home"
- "Which gemstone suits a Leo ascendant?"

**Scientific Astronomy:**
- "What is a black hole?"
- "How far is Saturn from the Sun?"
- "What are exoplanets?"

**Mixed:**
- "What is the role of Saturn in astrology and astronomy?"

## Features

- ✅ Dual expertise: Indian astrology + scientific astronomy
- ✅ Session-based conversation history
- ✅ Rate limiting (100 requests per 15 minutes)
- ✅ CORS enabled
- ✅ Security headers (Helmet.js)
- ✅ Concise responses (3-6 sentences)

## Tech Stack

- **Express.js** - Web framework
- **OpenAI API** - GPT-4o-mini model
- **Node-fetch** - HTTP client
- **fs-extra** - File operations

## Project Structure

```
src/
├── controllers/
│   └── chatController.js    # Chat endpoint handler
├── lib/
│   ├── openaiClient.js      # OpenAI API client
│   ├── retrieval.js         # System prompt
│   └── prompts.js           # Prompt templates
├── store/
│   └── history.json         # Session history (auto-generated)
└── server.js                # Express server
```

## Documentation

- **[QUICK_START.md](QUICK_START.md)** - Setup guide (5 minutes)
- **[API.md](API.md)** - Complete API reference
- **[FRONTEND_INTEGRATION.md](FRONTEND_INTEGRATION.md)** - Frontend integration examples

## Testing

```bash
# Run test script
npm run test:local

# Manual test with curl
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test-123",
    "message": "What is Saturn?"
  }'
```

## Notes

- Responses are 3-6 sentences for conciseness
- Session history stored in `src/store/history.json`
- No predictions or guarantees - only insights and context
- Balanced approach to science and spirituality

## License

ISC

---

**Version:** 3.0.0  
**Last Updated:** November 12, 2025
