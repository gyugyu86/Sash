#!/usr/bin/env bash
#
# notarize.sh — build, sign (Developer ID), notarize, and staple Sash for
# direct distribution. TEMPLATE / skeleton: this requires an Apple Developer
# account and a one-time notarytool credential setup (both human gates).
#
# Secrets are NEVER stored in this repo. Provide them via environment or a
# notarytool keychain profile:
#
#   # One-time: store credentials in the keychain (interactive, do this once)
#   xcrun notarytool store-credentials sash-notary \
#       --apple-id "you@example.com" \
#       --team-id "28T2JHJF87" \
#       --password "<app-specific-password>"
#
#   # Then run:
#   NOTARY_PROFILE=sash-notary ./Scripts/notarize.sh
#
set -euo pipefail

SCHEME="Sash"
APP_NAME="Sash"
TEAM_ID="${TEAM_ID:-28T2JHJF87}"
NOTARY_PROFILE="${NOTARY_PROFILE:-sash-notary}"
BUILD_DIR="build/release"

cd "$(dirname "$0")/.."

echo "==> Building $APP_NAME (Team $TEAM_ID)"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 1. Regenerate the project (project.yml is the single source of truth).
xcodegen generate

# 2. Archive a Release build (signing settings come from project.yml).
xcodebuild archive \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  -archivePath "$BUILD_DIR/$APP_NAME.xcarchive"

# 3. Export with Developer ID (direct distribution, not the App Store).
cat > "$BUILD_DIR/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key><string>developer-id</string>
  <key>teamID</key><string>$TEAM_ID</string>
  <key>signingStyle</key><string>automatic</string>
</dict>
</plist>
PLIST

xcodebuild -exportArchive \
  -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
  -exportPath "$BUILD_DIR/export"

APP_PATH="$BUILD_DIR/export/$APP_NAME.app"
# バージョンはビルド設定が解決済みの「成果物の Info.plist」から取得する
# （リポジトリの Sash/Info.plist は $(MARKETING_VERSION) の未解決リテラルなので使わない）。
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_PATH/Contents/Info.plist")"
ZIP_PATH="$BUILD_DIR/$APP_NAME-$VERSION.zip"
echo "==> Exported $APP_NAME $VERSION"

# 4. Zip the .app and submit to Apple's notary service (waits for the result).
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$NOTARY_PROFILE" --wait

# 5. Staple the ticket to the app and re-zip for distribution.
xcrun stapler staple "$APP_PATH"
rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "==> Done: $ZIP_PATH"
echo "    shasum -a 256:"
shasum -a 256 "$ZIP_PATH"
echo "    Update Casks/sash.rb (version + sha256) and attach the zip to the GitHub Release."
