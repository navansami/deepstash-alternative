#!/usr/bin/env bash
# Vercel has no native Flutter support: fetch the SDK, then build the web app.
# (Node deps for the /api function are installed by `npm ci` in vercel.json.)
set -euo pipefail

FLUTTER_VERSION="3.50.1"   # keep in sync with local SDK / pubspec.lock

if ! command -v unzip >/dev/null 2>&1; then
  dnf install -y unzip >/dev/null
fi

if [ ! -x flutter/bin/flutter ]; then
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git flutter
fi

export PATH="$PWD/flutter/bin:$PATH"
flutter config --no-analytics >/dev/null
flutter --version
flutter pub get
flutter build web --release

# Fail the deploy early if the API doesn't typecheck.
npx tsc --noEmit
