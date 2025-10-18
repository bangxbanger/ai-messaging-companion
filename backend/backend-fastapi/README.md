# Bro Backend (FastAPI + Groq)

FastAPI backend that uses Groq's LLM API to rephrase text with different tone profiles.

## Setup

```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set your Groq API key
export GROQ_API_KEY=your_groq_api_key_here

# Run the server
uvicorn main:app --reload --port 8080
```

The server will be available at `http://127.0.0.1:8080`

## API Endpoints

### GET /health
Health check endpoint.

**Response:**
```json
{ "ok": true }
```

### GET /profiles
Get available tone profiles.

**Response:**
```json
{ "profiles": ["formal", "bestie", "degen", "flirty"] }
```

### POST /rephrase
Rephrase text using selected tone profile.

**Request body:**
```json
{
  "text": "hey whats up",
  "profile": "formal"
}
```

**Response:**
```json
{
  "rephrased_text": "Hello, how are you doing?"
}
```

## Tone Profiles

- **formal**: Professional, precise, grammatically correct. No emojis.
- **bestie**: Warm, friendly, supportive. Light emojis ok.
- **degen**: Crypto degen slang, casual, irreverent. Emojis ok.
- **flirty**: Playful, light, respectful. Emojis ok.

## Testing

```bash
# Health check
curl http://127.0.0.1:8080/health

# Get profiles
curl http://127.0.0.1:8080/profiles

# Rephrase text
curl -X POST http://127.0.0.1:8080/rephrase \
  -H "Content-Type: application/json" \
  -d '{"text": "hey whats up", "profile": "formal"}'
```

## Notes

- Uses Groq's Chat Completions API (OpenAI-compatible)
- CORS enabled for local development
- No authentication required (for local dev only)
