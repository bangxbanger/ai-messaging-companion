import os
import json
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from groq import Groq
import uvicorn
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
if not GROQ_API_KEY:
    print("[WARN] GROQ_API_KEY not set. Set it before calling /rephrase.")
else:
    print(f"[INFO] GROQ_API_KEY loaded: {GROQ_API_KEY[:10]}...")

# Lazy-initialize client to avoid startup errors
_client = None

def get_client():
    global _client
    if _client is None:
        _client = Groq(api_key=GROQ_API_KEY or "")
    return _client

app = FastAPI(title="Bro Backend", version="0.1.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

PROFILES = {
    "nice_guy": (
        "Rewrite like a genuinely kind, thoughtful person who wants to sound polite, calm, and understanding. "
        "Empathetic phrasing, soft edges, add one emoji."
    ),
    "meme_god": (
        "Rewrite like someone who texts with pure vibes and no proofreading. "
        "Funny, dramatic, and unpredictable. Lowercase chaos with the occasional meme energy. Maybe one emoji."
    ),
    "no_filter": (
        "Rewrite like someone who has zero time for fluff. Direct, confident, and efficient. "
        "No filler words, no emojis, no hedging. Get to the point and move on."
    ),
}

class RephraseReq(BaseModel):
    text: str
    profile: str = "formal"

class RephraseResp(BaseModel):
    rephrased_text: str

@app.get("/health")
async def health():
    return {"ok": True}

@app.get("/profiles")
async def profiles():
    return {"profiles": list(PROFILES.keys())}

@app.post("/rephrase", response_model=RephraseResp)
async def rephrase(req: RephraseReq):
    if not req.text.strip():
        raise HTTPException(status_code=400, detail="text is required")
    if req.profile not in PROFILES:
        req.profile = "formal"
    system_prompt = f"""
    You are an AI message paraphraser.

    Your job: rephrase the user message to match the selected personality below,
    keeping the intent and meaning intact, while making it sound natural, sendable, and human.

    Personality Style:
    {PROFILES[req.profile]}

    Rules:
    - Keep it concise and send-ready.
    - Preserve mentions (@user), emojis, and URLs.
    - If the text already fits the tone, just lightly enhance it.
    - Output only the rewritten message, no explanations.
    - If you don't have an answer, return the original message.
    """
    if not GROQ_API_KEY:
        raise HTTPException(status_code=500, detail="GROQ_API_KEY not set")

    try:
        client = get_client()
        resp = client.chat.completions.create(
            model="openai/gpt-oss-20b",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": req.text},
            ],
            # temperature=0.7,
            # max_tokens=512,
        )
        rephrased = resp.choices[0].message.content.strip() if resp.choices else ""
        return {"rephrased_text": rephrased}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
        
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8080)
