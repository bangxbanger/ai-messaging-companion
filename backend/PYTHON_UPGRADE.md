# Upgrade Python to Fix httpx/openai Compatibility

## Current Issue
Python 3.9 + newer `openai` library = `__init__() got an unexpected keyword argument 'proxies'`

## Solution: Upgrade to Python 3.13

### Option 1: Install Python 3.13 via Homebrew (Recommended)

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Python 3.13
brew install python@3.13

# Verify installation
python3.13 --version
```

### Option 2: Download from python.org

1. Visit: https://www.python.org/downloads/
2. Download Python 3.13.x for macOS
3. Run the installer
4. Verify: `python3.13 --version`

## Recreate Virtual Environment with Python 3.13

```bash
cd /Users/bang.truong/Documents/Code/ai-messaging-companion/backend-fastapi

# Remove old virtual environment
rm -rf .venv

# Create new one with Python 3.13
python3.13 -m venv .venv

# Activate it
source .venv/bin/activate

# Verify Python version in venv
python --version  # Should show Python 3.13.x

# Reinstall dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Verify installation
pip list
```

## Start Server with New Python

```bash
cd /Users/bang.truong/Documents/Code/ai-messaging-companion/backend-fastapi
source .venv/bin/activate
uvicorn main:app --host 127.0.0.1 --port 8080 --reload
```

## Quick Test

After upgrading, test that it works:

```bash
# Terminal 1: Start server
cd backend-fastapi
source .venv/bin/activate
uvicorn main:app --host 127.0.0.1 --port 8080

# Terminal 2: Test it
curl http://127.0.0.1:8080/health
curl -X POST http://127.0.0.1:8080/rephrase \
  -H "Content-Type: application/json" \
  -d '{"text": "hey", "profile": "formal"}'
```

## Alternative: Use pyenv for Version Management

```bash
# Install pyenv
brew install pyenv

# Install Python 3.13
pyenv install 3.13.0

# Set it as local version for this project
cd /Users/bang.truong/Documents/Code/ai-messaging-companion/backend-fastapi
pyenv local 3.13.0

# Verify
python --version

# Recreate venv
rm -rf .venv
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Why This Fixes the Issue

Python 3.9 has an older `httpx` that conflicts with newer OpenAI/Groq SDKs.
Python 3.13 has updated dependencies that work correctly together.

The error `__init__() got an unexpected keyword argument 'proxies'` happens because:
- Old `httpx` in Python 3.9 ecosystem doesn't support `proxies` parameter
- New `openai` library expects it

Upgrading Python = upgrading the entire dependency ecosystem = no more conflicts!

