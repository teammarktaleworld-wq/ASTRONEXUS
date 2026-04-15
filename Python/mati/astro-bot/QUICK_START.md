# Quick Start Guide

Get AstroBot backend running in 5 minutes!

## Prerequisites

- Node.js v18 or higher
- OpenAI API key ([Get one here](https://platform.openai.com/api-keys))

## Installation

### 1. Install Dependencies
```bash
npm install
```

### 2. Setup Environment
```bash
cp .env.example .env
```

Edit `.env` and add your OpenAI API key:
```env
OPENAI_API_KEY=sk-your_actual_key_here
OPENAI_MODEL=gpt-4o-mini
PORT=3000
```

### 3. Start Server
```bash
npm start
```

Expected output:
```
Server listening on port 3000
```

## Test It!

Open a new terminal and run:

```bash
npm run test:local
```

Or use curl:

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test-123",
    "message": "What is the role of Saturn in astrology and astronomy?"
  }'
```

Expected response:
```json
{
  "ok": true,
  "answer": "Saturn plays dual roles in both astrology and astronomy...",
  "citations": [],
  "sources": []
}
```

## Available Commands

```bash
npm start          # Start production server
npm run dev        # Start with auto-reload (development)
npm run test:local # Test the chat API
```

## Project Structure

```
astro-bot/
├── src/
│   ├── controllers/
│   │   └── chatController.js    # Chat endpoint handler
│   ├── lib/
│   │   ├── openaiClient.js      # OpenAI API client
│   │   ├── retrieval.js         # System prompt
│   │   └── prompts.js           # Prompt templates
│   ├── store/
│   │   └── history.json         # Session history (auto-generated)
│   └── server.js                # Express server
├── scripts/
│   └── testLocalChat.js         # Test script
├── .env                         # Your configuration (create this)
├── .env.example                 # Environment template
├── package.json                 # Dependencies
├── README.md                    # Main documentation
└── API.md                       # API reference
```

## Troubleshooting

### "OPENAI_API_KEY is not set"
→ Make sure you created `.env` and added your API key

### "ECONNREFUSED"
→ Make sure the server is running with `npm start`

### Port already in use
→ Change `PORT=3000` to another port in `.env`

## Example Questions

Try asking:
- "What does it mean if my Moon is in Scorpio?"
- "Give vastu tips for a north-facing home"
- "What is a black hole?"
- "What is the role of Saturn in astrology and astronomy?"

## Next Steps

1. ✅ Server is running
2. ✅ Test query works
3. 🚀 Integrate with your frontend
4. 📖 Read [API.md](API.md) for complete API documentation

## Need Help?

- Check [API.md](API.md) for complete API documentation
- Check [README.md](README.md) for project overview

---

**Version:** 3.0.0  
**Last Updated:** November 12, 2025
