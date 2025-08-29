#!/usr/bin/env bash
set -euo pipefail

# --- Locate toolchain ---
TOOLCHAIN="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"

CF="$TOOLCHAIN/clang-format"
SF="$TOOLCHAIN/swift-format"

if [[ ! -x "$CF" ]]; then
  echo "ERROR: clang-format not found in $TOOLCHAIN" >&2
  exit 1
fi

echo "Using clang-format: $("$CF" --version)"

# --- Format Obj-C / C / C++ ---
echo "Formatting Obj-C/C/C++ files..."
find . \( -name "*.[mh]" -o -name "*.mm" -o -name "*.c" -o -name "*.cpp" \) -type f \
  -exec "$CF" -style=file -i {} +

# --- Format Swift ---
if [[ -x "$SF" ]]; then
  echo "Using swift-format: $("$SF" --version || echo 'installed')"
  if [[ -f .swift-format ]]; then
    "$SF" -i -r . --configuration .swift-format
  else
    "$SF" -i -r .
  fi
else
  echo "swift-format not found in $TOOLCHAIN; skipping Swift files."
fi

echo "Done."
