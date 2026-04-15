# Unified Wrapper API

This backend now exposes a single URL namespace for:
- Birth chart (FastAPI service)
- Horoscope (Node horoscope service)
- Mati chatbot (Node chatbot service)

Base URL:

```text
http://localhost:8001/api/unified
```

## Service URL Mapping

Configure these in `backend/.env` (or Render environment variables):

```env
BIRTH_CHART_SERVICE_URL=http://127.0.0.1:8010
HOROSCOPE_SERVICE_URL=http://127.0.0.1:4000
MATI_CHAT_SERVICE_URL=http://127.0.0.1:3000
UNIFIED_PROXY_TIMEOUT_MS=45000
```

## Endpoints

### 1) Health Check for All Three Services

```http
GET /api/unified/health
```

Returns up/down status for birth chart, horoscope, and Mati services.

### 2) Birth Chart Proxy

```http
POST /api/unified/birth-chart
Content-Type: application/json
```

Request body example:

```json
{
  "name": "Aarav",
  "gender": "male",
  "birth_date": { "year": 1998, "month": 7, "day": 15 },
  "birth_time": { "hour": 8, "minute": 30, "ampm": "AM" },
  "place_of_birth": "Mumbai, India",
  "astrology_type": "vedic",
  "ayanamsa": "lahiri"
}
```

### 3) Horoscope Proxy

```http
GET /api/unified/horoscope?sign=aries&type=daily&day=TODAY
```

Query params:
- `sign` required (aries..pisces)
- `type` optional: `daily|weekly|monthly` (default `daily`)
- `day` optional for daily: `TODAY|TOMORROW|YESTERDAY` (default `TODAY`)

### 4) Mati Chat Proxy

```http
POST /api/unified/mati-chat
Content-Type: application/json
```

Request body example:

```json
{
  "sessionId": "user-123",
  "message": "Will this week be good for career decisions?"
}
```

### 5) Aggregate Wrapper (One Call for Multiple Services)

```http
POST /api/unified/aggregate
Content-Type: application/json
```

Request body example:

```json
{
  "birthChart": {
    "name": "Aarav",
    "gender": "male",
    "birth_date": { "year": 1998, "month": 7, "day": 15 },
    "birth_time": { "hour": 8, "minute": 30, "ampm": "AM" },
    "place_of_birth": "Mumbai, India",
    "astrology_type": "vedic",
    "ayanamsa": "lahiri"
  },
  "horoscope": {
    "sign": "aries",
    "type": "daily",
    "day": "TODAY"
  },
  "matiChat": {
    "sessionId": "user-123",
    "message": "Give me astrological guidance for today."
  }
}
```

Response includes per-service success/error so frontend can render partial results.

## Local Run (Windows PowerShell)

1. Install dependencies:

```powershell
cd backend; npm install
cd ../Python/horoscope/astronexus-horoscope; npm install
cd ../Python/mati/astro-bot; npm install
py -3.11 -m venv ..\..\birth_chart\astro-nexus-backend\.venv
..\birth_chart\astro-nexus-backend\.venv\Scripts\python -m pip install -r ..\birth_chart\astro-nexus-backend\requirements.txt
```

2. Start only the backend index file (it auto-starts internal services):

```powershell
cd backend
$env:UNIFIED_AUTOSTART="true"
$env:SKIP_DB="true"
node index.js
```

## Render Single Deployment (No Separate Services)

Use one Render web service with:
- Build command installing all Node + Python dependencies
- Start command: `cd backend && node index.js`

Create `render.yaml` at repo root and set required secrets in Render dashboard:
- `MONGODB_URI`, `JWT_SECRET`, API keys, and chatbot provider key (`OPENAI_API_KEY` or `GROQ_API_KEY` in `Python/mati/astro-bot`)
- `UNIFIED_AUTOSTART=true` (so backend auto-launches birth chart, horoscope, and Mati services)
