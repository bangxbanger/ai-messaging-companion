#!/bin/bash

# Start FastAPI backend with Python 3.13
cd "$(dirname "$0")"

echo "🐍 Using Python 3.13..."
source .venv/bin/activate

echo "📦 Installing dependencies..."
pip install --upgrade pip --quiet
pip install -r requirements.txt --quiet

echo "🔑 Loading GROQ_API_KEY from .env..."
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

echo "🚀 Starting FastAPI server on http://127.0.0.1:8080"
echo "Press Ctrl+C to stop"
echo ""

uvicorn main:app --host 127.0.0.1 --port 8080 --reload

