#!/bin/bash
set -e

echo "=== CoolNet AI — Vercel Flutter Web Build Pipeline ==="

# 1. Detect or provision Flutter SDK
if ! command -v flutter &> /dev/null; then
  INSTALL_DIR="/tmp/flutter"
  if [ ! -f "$INSTALL_DIR/bin/flutter" ]; then
    echo "[1/5] Flutter SDK not detected in PATH. Cloning Flutter 3.47.8 into ${INSTALL_DIR}..."
    rm -rf "$INSTALL_DIR"
    git clone https://github.com/flutter/flutter.git --depth 1 -b 3.47.8 "$INSTALL_DIR"
  else
    echo "[1/5] Using existing Flutter SDK cached at ${INSTALL_DIR}."
  fi
  export PATH="$INSTALL_DIR/bin:$PATH"
  git config --global --add safe.directory "$INSTALL_DIR" || true
else
  echo "[1/5] Using existing Flutter SDK from PATH."
fi

echo "Active Flutter version:"
flutter --version

# 2. Disable telemetry & configure web
echo "[2/5] Configuring Flutter environment..."
flutter config --no-analytics
flutter config --enable-web

# 3. Fetch dependencies and run validation
echo "[3/5] Resolving dependencies and running tests..."
flutter pub get
flutter analyze
flutter test

# 4. Resolve Production API Base URL
TARGET_API_URL="${API_BASE_URL:-https://coolnet-ai-backend.onrender.com}"
if [[ "$TARGET_API_URL" == *"localhost"* ]] || [[ "$TARGET_API_URL" == *"127.0.0.1"* ]] || [[ -z "$TARGET_API_URL" ]]; then
  echo "Notice: Overriding local/empty API_BASE_URL to live Render backend for Vercel deployment."
  TARGET_API_URL="https://coolnet-ai-backend.onrender.com"
fi
echo "[4/5] Targeting Backend API Base URL: ${TARGET_API_URL}"

# 5. Build optimized Flutter Web release bundle
echo "[5/5] Compiling Flutter Web release bundle..."
flutter build web --release --dart-define=API_BASE_URL="${TARGET_API_URL}"

# 6. Verify build output integrity
if [ ! -f "build/web/index.html" ]; then
  echo "ERROR: build/web/index.html not found after build!"
  exit 1
fi

echo "=== Build succeeded! Production artifacts verified in build/web ==="
