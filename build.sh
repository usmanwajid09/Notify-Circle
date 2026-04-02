#!/bin/bash
set -e

echo "=== Downloading Flutter SDK 3.19.5 ==="
# We use the specific version known to be compatible with exactly our configured dependencies
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.5-stable.tar.xz
tar xf flutter_linux_3.19.5-stable.tar.xz

# Temporarily add Flutter to the PATH of the Vercel build container
export PATH="$PATH:`pwd`/flutter/bin"

echo "=== Installing dependencies ==="
flutter config --no-analytics
flutter pub get

echo "=== Building Flutter Web application ==="
flutter build web --release

echo "=== Build Execution Finished ==="
