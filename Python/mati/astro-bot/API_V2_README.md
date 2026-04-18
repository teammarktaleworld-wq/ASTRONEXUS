# AstroBot API V2 Documentation

This updated API provides structured astrological analysis suitable for frontend visualizations (like pie charts and planet breakdown lists).

## Base URL
`http://localhost:3000/api`

---

## 🚀 Chat & Analysis Endpoint
`POST /chat`

Use this endpoint to get astrological advice and structured data for decision-making.

### Request Body
```json
{
  "sessionId": "unique-session-id",
  "message": "Should I buy a car today?",
  "userProfile": {
    "birthDate": "1995-05-15",
    "birthTime": "14:30",
    "birthPlace": "Mumbai, India",
    "zodiacSign": "Taurus"
  }
}
```

### Response Body
```json
{
  "ok": true,
  "answer": "A detailed written report explaining the astrological reasoning...",
  "analysis": {
    "decisionScore": 80,
    "agreementPercentage": 80,
    "disagreementPercentage": 20,
    "planetBreakdown": [
      {
        "planet": "Jupiter",
        "status": "agree",
        "reason": "Favorable transit in the 10th house."
      },
      {
        "planet": "Saturn",
        "status": "disagree",
        "reason": "Caution advised due to retrograde."
      }
    ]
  },
  "rawModelResponse": {
    "model": "llama-3.3-70b-versatile",
    "usage": { ... }
  }
}
```

#### Frontend Integration Notes:
- **Pie Chart**: Use `analysis.agreementPercentage` and `analysis.disagreementPercentage`.
- **Planet List**: Map over `analysis.planetBreakdown` to show which planets agree or disagree and why.

---

## 👤 User Profile Endpoints
These endpoints are placeholders for future database integration. Currently, they use a local JSON file store.

### Get Profile
`GET /profile/:userId`

**Response:**
```json
{
  "ok": true,
  "profile": {
    "birthDate": "1995-05-15",
    "birthTime": "14:30",
    "birthPlace": "Mumbai, India",
    "zodiacSign": "Taurus",
    "updatedAt": "2026-02-16T..."
  }
}
```

### Save/Update Profile
`POST /profile`

**Request Body:**
```json
{
  "userId": "user-123",
  "profile": {
    "birthDate": "1995-05-15",
    "birthTime": "14:30",
    "birthPlace": "Mumbai, India",
    "zodiacSign": "Taurus"
  }
}
```

---

## 🛠 Database Integration Guide
To move from Mock (JSON file) to MongoDB:
1. Update `src/controllers/userController.js`.
2. Replace `fs-extra` logic with Mongoose `User.find()` and `User.save()`.
3. Add MongoDB connection logic in `src/server.js`.
