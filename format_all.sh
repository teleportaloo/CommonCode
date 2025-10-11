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
   echo Using:
    cat .swift-format
    "$SF" -i -r . --configuration .swift-format
  else
    "$SF" -i -r .
  fi
else
  echo "swift-format not found in $TOOLCHAIN; skipping Swift files."
fi

# --- Format JavaScript / HTML / CSS / JSON / Markdown with Prettier ---
if command -v prettier >/dev/null 2>&1; then
  echo "Using Prettier: $(prettier --version)"

  PRETTIER_ARGS=""
  IGNORE_FILE=".prettier-ignore-extra"

  # Default to no semicolons if no Prettier config
  if [[ ! -f .prettierrc && ! -f .prettierrc.json && ! -f .prettierrc.yml && \
        ! -f .prettierrc.yaml && ! -f .prettierrc.js && \
        ! -f prettier.config.js && ! -f prettier.config.cjs && ! -f prettier.config.mjs && \
        ! -f package.json ]]; then
    PRETTIER_ARGS="--no-semi"
  fi

  # Load additional ignores
  if [[ -f "$IGNORE_FILE" ]]; then
    echo "Applying custom ignore patterns from $IGNORE_FILE"
    # Create a temporary ignore file that merges with Prettier’s default .prettierignore
    TMP_IGNORE="$(mktemp)"
    if [[ -f .prettierignore ]]; then
      cat .prettierignore > "$TMP_IGNORE"
    fi
    cat "$IGNORE_FILE" >> "$TMP_IGNORE"
    PRETTIER_ARGS="$PRETTIER_ARGS --ignore-path $TMP_IGNORE"
  fi

  prettier_extensions="js jsx ts tsx json html htm css md"
  for ext in $prettier_extensions; do
    echo "Formatting *.$ext files with Prettier..."
    find . -type f -name "*.${ext}" ! -path "*/.*" ! -path "*/node_modules/*" -print0 |
      xargs -0 prettier --write --loglevel warn $PRETTIER_ARGS || true
  done

  # Clean up temp ignore file
  [[ -n "${TMP_IGNORE:-}" && -f "$TMP_IGNORE" ]] && rm -f "$TMP_IGNORE"

else
  echo "Prettier not found; skipping JS/HTML/CSS formatting."
  echo "Install with: npm install -g prettier"
fi

echo "Done."
