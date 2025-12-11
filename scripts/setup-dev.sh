#!/usr/bin/env bash
set -e

# Create necessary directories
PROJECT_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
UPLOADS="$PROJECT_ROOT/uploads"
DATA="$PROJECT_ROOT/data"

mkdir -p "$UPLOADS"
mkdir -p "$DATA"

# Ensure videos.json exists
VIDEOS_FILE="$DATA/videos.json"
if [ ! -f "$VIDEOS_FILE" ]; then
  echo '[]' > "$VIDEOS_FILE"
fi

# Copy .env.example to .env if missing
ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"
if [ ! -f "$ENV_FILE" ] && [ -f "$ENV_EXAMPLE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
fi

# Optionally run a CLI tools check
for arg in "$@"; do
  case $arg in
    --check) CHECK_TOOLS=1; shift ;;
  esac
done

if [ ! -z "$CHECK_TOOLS" ]; then
  if command -v bash >/dev/null 2>&1; then
    scripts/check-tools.sh || true
  fi
fi

# Optional: install dependencies unless SKIP_DEPS is set
if [ -z "$SKIP_DEPS" ]; then
  if command -v npm >/dev/null 2>&1; then
    npm install
  else
    echo "npm not found. Please install Node.js/npm"
  fi
fi

echo "Setup complete. Run 'npm run dev' to start the app." 
