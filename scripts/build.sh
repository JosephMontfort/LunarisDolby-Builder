#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANDROID_DIR="$ROOT_DIR/android"

mkdir -p "$ANDROID_DIR"
cd "$ANDROID_DIR"

if [ ! -d .repo ]; then
    repo init \
        -u https://github.com/crdroidandroid/android.git \
        -b 16.0 \
        --depth=1
fi

mkdir -p .repo/local_manifests
cp "$ROOT_DIR/local_manifests/lunaris.xml" .repo/local_manifests/

repo sync \
    packages/apps/LunarisDolby \
    frameworks/base \
    build/make \
    build/soong \
    build/blueprint \
    build/release \
    system/core \
    system/libbase \
    system/logging \
    prebuilts/jdk/jdk21 \
    -j8

set +u
source build/envsetup.sh
set -u

lunch aosp_arm64-userdebug

m LunarisDolby
