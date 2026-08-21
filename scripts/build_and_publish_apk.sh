#!/usr/bin/env bash
set -e

VERSION="${1:-1.0.0}"
BUILD_TYPE="${2:-release}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DOWNLOADS_DIR="$(cd "$FRONTEND_DIR/../artisansApp_backend" && pwd)/public/downloads"

echo "=========================================================="
echo "  CraftMatch Android APK Builder & Packager               "
echo "  Version: $VERSION | Build Type: $BUILD_TYPE              "
echo "=========================================================="

cd "$FRONTEND_DIR"

echo -e "\n[1/4] Fetching Flutter dependencies..."
flutter pub get

echo -e "\n[2/4] Compiling Android APK ($BUILD_TYPE)..."
if [ "$BUILD_TYPE" = "debug" ]; then
    flutter build apk --debug --build-name="$VERSION"
    SOURCE_APK="build/app/outputs/flutter-apk/app-debug.apk"
else
    flutter build apk --release --build-name="$VERSION"
    SOURCE_APK="build/app/outputs/flutter-apk/app-release.apk"
fi

if [ ! -f "$SOURCE_APK" ]; then
    echo "Error: Build finished but APK was not found at $SOURCE_APK"
    exit 1
fi

echo -e "\n[3/4] Packaging & Staging Distribution Artifacts..."
mkdir -p "$BACKEND_DOWNLOADS_DIR"

VERSIONED_TARGET="$BACKEND_DOWNLOADS_DIR/CraftMatch-v$VERSION.apk"
LATEST_TARGET="$BACKEND_DOWNLOADS_DIR/CraftMatch-latest.apk"

cp "$SOURCE_APK" "$VERSIONED_TARGET"
cp "$SOURCE_APK" "$LATEST_TARGET"

FILE_SIZE_BYTES=$(stat -c%s "$LATEST_TARGET" 2>/dev/null || stat -f%z "$LATEST_TARGET")
FILE_SIZE_MB=$(awk "BEGIN {printf \"%.1f MB\", $FILE_SIZE_BYTES/1048576}")
SHA256_HASH=$(sha256sum "$LATEST_TARGET" 2>/dev/null | awk '{print $1}' || shasum -a 256 "$LATEST_TARGET" | awk '{print $1}')

echo -e "\n[4/4] Generating Release Manifest..."
cat <<EOF > "$BACKEND_DOWNLOADS_DIR/release-manifest.json"
{
  "appName": "CraftMatch",
  "latestVersion": "$VERSION",
  "updatedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "links": [
    {
      "platform": "android",
      "label": "Android APK",
      "href": "/api/releases/download/android",
      "version": "$VERSION",
      "fileSize": "$FILE_SIZE_MB",
      "fileSizeBytes": $FILE_SIZE_BYTES,
      "sha256": "$SHA256_HASH",
      "minRequirement": "Android 8.0 or newer",
      "available": true,
      "external": false
    },
    {
      "platform": "web",
      "label": "Web PWA",
      "href": "https://artisans-app-frontend.vercel.app/",
      "version": "$VERSION",
      "minRequirement": "Latest Chrome, Edge, Safari, or Firefox",
      "available": true,
      "external": true
    },
    {
      "platform": "ios",
      "label": "iPhone",
      "href": "",
      "version": "$VERSION",
      "minRequirement": "iOS 15 or newer",
      "available": false,
      "external": true
    },
    {
      "platform": "windows",
      "label": "Windows",
      "href": "",
      "version": "$VERSION",
      "minRequirement": "Windows 10 or newer",
      "available": false,
      "external": true
    },
    {
      "platform": "macos",
      "label": "macOS",
      "href": "",
      "version": "$VERSION",
      "minRequirement": "macOS 12 or newer",
      "available": false,
      "external": true
    }
  ]
}
EOF

echo -e "\n=========================================================="
echo "  Build & Packaging Succeeded!                            "
echo "  Target APK: $LATEST_TARGET ($FILE_SIZE_MB)"
echo "  SHA256:     $SHA256_HASH"
echo "=========================================================="
