#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="${ANDROID_DIR:-$ROOT_DIR/android}"
ROM_MANIFEST_URL="${ROM_MANIFEST_URL:-https://github.com/crdroidandroid/android}"
ROM_BRANCH="${ROM_BRANCH:-16.0}"
LUNCH_TARGET="${LUNCH_TARGET:-crdroid_garnet-userdebug}"
MODULE_NAME="${MODULE_NAME:-LunarisDolby}"
JOBS="${JOBS:-$(nproc)}"

mkdir -p "$ANDROID_DIR"
cd "$ANDROID_DIR"

if [ ! -d .repo ]; then
    repo init -u "$ROM_MANIFEST_URL" -b "$ROM_BRANCH" --depth=1
fi

mkdir -p .repo/local_manifests
cp "$ROOT_DIR/local_manifests/lunaris.xml" .repo/local_manifests/lunaris.xml

repo sync -c --force-sync --force-remove-dirty --no-tags --no-clone-bundle -j"$JOBS"

source build/envsetup.sh
lunch "$LUNCH_TARGET"

m "$MODULE_NAME" -j"$JOBS"

mkdir -p "$ROOT_DIR/artifacts"
APK_PATH="$(find out/target/product -type f -name "${MODULE_NAME}.apk" | head -n 1)"

if [ -z "${APK_PATH:-}" ]; then
    echo "APK not found after build" >&2
    exit 1
fi

cp -f "$APK_PATH" "$ROOT_DIR/artifacts/${MODULE_NAME}.apk"
echo "APK copied to: $ROOT_DIR/artifacts/${MODULE_NAME}.apk"
