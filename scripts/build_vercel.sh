#!/bin/bash
set -e

echo "=== CoolNet AI — Vercel Flutter Web Build Pipeline ==="

# 1. Detect or provision Flutter SDK
if ! command -v flutter &> /dev/null; then
  echo "[1/5] Flutter SDK not detected in PATH. Provisioning Flutter 3.24.5..."
  INSTALL_DIR="/tmp/flutter"
  if [ ! -d "$INSTALL_DIR" ]; then
    git clone https://github.com/flutter/flutter.git --depth 1 -b 3.24.5 "$INSTALL_DIR"
  fi
  export PATH="$INSTALL_DIR/bin:$PATH"
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
# If API_BASE_URL is set in Vercel Environment Variables, use it; otherwise default to target Render URL
TARGET_API_URL="${API_BASE_URL:-https://coolnet-ai-backend.onrender.com}"
echo "[4/5] Targeting Backend API Base URL: ${TARGET_API_URL}"

# 5. Build optimized Flutter Web release bundle
echo "[5/5] Compiling Flutter Web release bundle..."
flutter build web --release --dart-define=API_BASE_URL="${TARGET_API_URL}"

echo "=== Build succeeded! Production artifacts ready in build/web ==="
