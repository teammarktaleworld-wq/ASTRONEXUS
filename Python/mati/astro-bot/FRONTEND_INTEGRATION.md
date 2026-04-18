# Frontend Integration Guide

Quick guide for frontend developers to integrate with AstroBot backend.

## API Endpoint

```
POST http://localhost:3000/api/chat
```

## Request Format

```javascript
{
  sessionId: "unique-session-id",  // Required: Use same ID for conversation
  message: "Your question here"     // Required: User's question
}
```

## Response Format

```javascript
{
  ok: true,
  answer: "AI-generated answer (3-6 sentences)",
  analysis: {
    decisionScore: 85,
    positivePercentage: 85,
    negativePercentage: 15,
    planetBreakdown: [...]
  },
  shopSuggestions: [
    {
      id: "p1",
      name: "Product Name",
      description: "...",
      price: 499,
      currency: "INR",
      shopUrl: "..."
    }
  ],
  citations: [],
  sources: [],
  rawModelResponse: {
    model: "gpt-4o-mini",
    usage: { total_tokens: 245 }
  }
}

```

## React Example

```jsx
import { useState } from 'react';

function ChatBot() {
  const [message, setMessage] = useState('');
  const [response, setResponse] = useState(null);
  const [loading, setLoading] = useState(false);
  const [sessionId] = useState(`session-${Date.now()}`);

  const sendMessage = async () => {
    setLoading(true);
    try {
      const res = await fetch('http://localhost:3000/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sessionId, message }),
      });
      const data = await res.json();
      setResponse(data);
    } catch (error) {
      console.error('Error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <input
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        placeholder="Ask about astrology or astronomy..."
      />
      <button onClick={sendMessage} disabled={loading}>
        {loading ? 'Thinking...' : 'Ask'}
      </button>
      {response && <p>{response.answer}</p>}
    </div>
  );
}
```

## Vue Example

```vue
<template>
  <div>
    <input
      v-model="message"
      @keyup.enter="sendMessage"
      placeholder="Ask about astrology or astronomy..."
    />
    <button @click="sendMessage" :disabled="loading">
      {{ loading ? 'Thinking...' : 'Ask' }}
    </button>
    <p v-if="response">{{ response.answer }}</p>
  </div>
</template>

<script>
export default {
  data() {
    return {
      message: '',
      response: null,
      loading: false,
      sessionId: `session-${Date.now()}`,
    };
  },
  methods: {
    async sendMessage() {
      this.loading = true;
      try {
        const res = await fetch('http://localhost:3000/api/chat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            sessionId: this.sessionId,
            message: this.message,
          }),
        });
        this.response = await res.json();
      } catch (error) {
        console.error('Error:', error);
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>
```

## Vanilla JavaScript Example

```javascript
const sessionId = `session-${Date.now()}`;

async function askQuestion(message) {
  const response = await fetch('http://localhost:3000/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ sessionId, message }),
  });
  
  const data = await response.json();
  return data.answer;
}

// Usage
const answer = await askQuestion('What is Saturn?');
console.log(answer);
```

## Important Notes

### Session Management
- Use the **same sessionId** for an entire conversation
- Generate a new sessionId for each new conversation
- Format: `session-${timestamp}` or any unique string

### Response Characteristics
- Answers are **3-6 sentences** (concise)
- Covers both **Indian astrology** and **scientific astronomy**
- Balanced, positive, educational tone
- No predictions or guarantees

### Error Handling

```javascript
try {
  const res = await fetch('http://localhost:3000/api/chat', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ sessionId, message }),
  });
  
  const data = await res.json();
  
  if (!data.ok) {
    console.error('Error:', data.error);
    return;
  }
  
  console.log(data.answer);
} catch (error) {
  console.error('Network error:', error);
}
```

### CORS
CORS is enabled for all origins in development. For production, configure specific origins.

### Rate Limiting
- 100 requests per 15 minutes per IP
- Handle 429 status code appropriately

## Example Questions

### Indian Astrology
```javascript
"What does it mean if my Moon is in Scorpio?"
"Give vastu tips for a north-facing home"
"Which gemstone suits a Leo ascendant?"
```

### Scientific Astronomy
```javascript
"What is a black hole?"
"How far is Saturn from the Sun?"
"What are exoplanets?"
```

### Mixed
```javascript
"What is the role of Saturn in astrology and astronomy?"
"Tell me about Mars from both perspectives"
```

## Testing

Test the backend before integrating:

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "sessionId": "test-123",
    "message": "What is Saturn?"
  }'
```

## Complete API Documentation

See [API.md](API.md) for complete API reference.

---

**Version:** 3.0.0  
**Last Updated:** November 12, 2025
