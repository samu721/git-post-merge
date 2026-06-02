#!/usr/bin/env bash
set -euo pipefail

echo "Starting full build + test process..."

echo "Configuring Git hooks..."

git config core.hooksPath .git/hooks

echo "Making hooks executable..."

# chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/post-merge

echo "Setup complete."
echo "Git hooks are now configured for this repository."

# -----------------------------
# 1. Create venv if missing
# -----------------------------
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Always use venv python explicitly (more reliable than source)
VENV_PY="venv/bin/python"

# -----------------------------
# 2. Upgrade pip
# -----------------------------
echo "Upgrading pip..."
$VENV_PY -m pip install --upgrade pip

# -----------------------------
# 3. Install dependencies
# -----------------------------
echo "Installing dependencies..."
$VENV_PY -m pip install -r requirements.txt

# -----------------------------
# 4. Run app
# -----------------------------
echo "Running app.py..."
$VENV_PY app.py

# -----------------------------
# 5. JSON validation (good file)
# -----------------------------
echo "Checking good.json..."
$VENV_PY -m json.tool good.json > /dev/null
echo "good.json is VALID"

# -----------------------------
# 6. JSON validation (bad file)
# -----------------------------
echo "Checking bad.json..."

if ! $VENV_PY -m json.tool bad.json > /dev/null 2>&1; then
    echo "bad.json is INVALID (expected behavior)"
else
    echo "❌ WARNING: bad.json should have failed but didn't"
    exit 1
fi

echo "Build + app run + JSON tests completed successfully!"