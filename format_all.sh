#!/usr/bin/env bash
# This formats Objective-C, C, C++, HTML, JSON, JS, Swift...
# There are some ignore files:
# .clang-format-ignore
# .swift-format-ignore
# .prettier-ignore-extra

set -euo pipefail

# -------- Locate toolchain --------
TOOLCHAIN="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin"
CF="$TOOLCHAIN/clang-format"
SF="$TOOLCHAIN/swift-format"

if [[ ! -x "$CF" ]]; then
  echo "ERROR: clang-format not found in $TOOLCHAIN" >&2
  exit 1
fi

echo "Using clang-format: $("$CF" --version)"

# -------- Helpers --------
TMPFILES=()
cleanup() {
  for f in "${TMPFILES[@]:-}"; do
    [[ -n "${f:-}" && -f "$f" ]] && rm -f "$f" || true
  done
}
trap cleanup EXIT INT TERM

# strip comments/blank lines from an ignore file -> output clean file
clean_ignore_file() {
  local in="$1" out="$2"
  [[ -f "$in" ]] || { : > "$out"; return; }
  # remove trailing spaces, comments, blanks
  sed -e 's/[[:space:]]\+$//' -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$in" > "$out"
}

# parse a “formatter ignore” file into two clean lists:
#   * dirs_to_prune: lines considered directories (e.g., Path/, Path/**, Path/*, or no extension)
#   * files_to_skip: explicit files (ending with .swift/.m/.h/.mm/.c/.cpp etc.)
# outputs: two temp files (paths), passed back via echo (DIRS_FILE FILES_FILE)
parse_ignore_to_dirs_files() {
  local in="$1" kind="$2"  # kind: swift|clang
  local cleaned="$(mktemp)"; TMPFILES+=("$cleaned")
  clean_ignore_file "$in" "$cleaned"

  local dirs="$(mktemp)"; TMPFILES+=("$dirs")
  local files="$(mktemp)"; TMPFILES+=("$files")

  local exts_swift="swift"
  local exts_clang="m h mm c cpp"

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    # normalize ./ prefix for find -path matching
    [[ "$line" != ./* ]] && line="./$line"

    # drop trailing /** or /* or /
    local base="$line"
    base="${base%/**}"
    base="${base%/*}"
    base="${base%/}"

    # decide if file or dir based on extension
    case "$kind" in
      swift)
        case "$base" in
          *.swift) echo "$base" >> "$files" ;;
          *)       echo "$base" >> "$dirs" ;;
        esac
        ;;
      clang)
        case "$base" in
          *.m|*.h|*.mm|*.c|*.cpp) echo "$base" >> "$files" ;;
          *)                      echo "$base" >> "$dirs" ;;
        esac
        ;;
    esac
  done < "$cleaned"

  echo "$dirs" "$files"
}

# -------- Format Obj-C / C / C++ (clang-format) --------
echo "Formatting Obj-C/C/C++ files..."
CLANG_IGNORE_FILE=".clang-format-ignore"
if [[ -f "$CLANG_IGNORE_FILE" ]]; then
  echo "Applying ignore patterns from $CLANG_IGNORE_FILE"
  read -r CLANG_DIRS_FILE CLANG_FILES_FILE < <(parse_ignore_to_dirs_files "$CLANG_IGNORE_FILE" "clang")
  # Build a prune-capable find command
  # Example: find . \( -path ./Highlightr -o -path ./BoostBLEKit \) -prune -o (…types…) -print0
  if [[ -s "$CLANG_DIRS_FILE" ]]; then
    # shellcheck disable=SC2013
    PRUNE_EXPR=( \( )
    first=true
    while IFS= read -r d; do
      [[ -z "$d" ]] && continue
      if $first; then first=false; else PRUNE_EXPR+=( -o ); fi
      PRUNE_EXPR+=( -path "$d" )
    done < "$CLANG_DIRS_FILE"
    PRUNE_EXPR+=( \) -prune -o )
  else
    PRUNE_EXPR=()
  fi

  FIND_CMD=(find . "${PRUNE_EXPR[@]}" \( -name "*.[mh]" -o -name "*.mm" -o -name "*.c" -o -name "*.cpp" \) -type f ! -path "*/.*" -print0)

  if [[ -s "$CLANG_FILES_FILE" ]]; then
    # Exclude explicit files, then format
    "${FIND_CMD[@]}" \
      | xargs -0 -I{} echo "{}" \
      | grep -vFf "$CLANG_FILES_FILE" \
      | while IFS= read -r file; do
          [[ -n "$file" ]] && "$CF" -style=file -i "$file"
        done
  else
    "${FIND_CMD[@]}" | xargs -0 "$CF" -style=file -i
  fi
else
  find . \( -name "*.[mh]" -o -name "*.mm" -o -name "*.c" -o -name "*.cpp" \) -type f ! -path "*/.*" -exec "$CF" -style=file -i {} +
fi

# -------- Format Swift (swift-format) --------
if [[ -x "$SF" ]]; then
  echo "Using swift-format: $("$SF" --version || echo 'installed')"

  SWIFT_CFG_ARGS=""
  if [[ -f .swift-format ]]; then
    echo "Using .swift-format configuration:"
    cat .swift-format
    SWIFT_CFG_ARGS="--configuration .swift-format"
  fi

  SWIFT_IGNORE_FILE=".swift-format-ignore"
  if [[ -f "$SWIFT_IGNORE_FILE" ]]; then
    echo "Applying ignore patterns from $SWIFT_IGNORE_FILE"
    read -r SWIFT_DIRS_FILE SWIFT_FILES_FILE < <(parse_ignore_to_dirs_files "$SWIFT_IGNORE_FILE" "swift")

    # Build prune-able find for Swift
    if [[ -s "$SWIFT_DIRS_FILE" ]]; then
      PRUNE_EXPR=( \( )
      first=true
      while IFS= read -r d; do
        [[ -z "$d" ]] && continue
        if $first; then first=false; else PRUNE_EXPR+=( -o ); fi
        PRUNE_EXPR+=( -path "$d" )
      done < "$SWIFT_DIRS_FILE"
      PRUNE_EXPR+=( \) -prune -o )
    else
      PRUNE_EXPR=()
    fi

    FIND_CMD=(find . "${PRUNE_EXPR[@]}" -type f -name "*.swift" ! -path "*/.*" -print0)

    if [[ -s "$SWIFT_FILES_FILE" ]]; then
      "${FIND_CMD[@]}" \
        | xargs -0 -I{} echo "{}" \
        | grep -vFf "$SWIFT_FILES_FILE" \
        | while IFS= read -r swiftfile; do
            [[ -n "$swiftfile" ]] && $SF -i $SWIFT_CFG_ARGS "$swiftfile"
          done
    else
      "${FIND_CMD[@]}" | xargs -0 -I{} $SF -i $SWIFT_CFG_ARGS "{}"
    fi
  else
    # No ignore file -> recursive format
    if [[ -n "$SWIFT_CFG_ARGS" ]]; then
      $SF -i -r . $SWIFT_CFG_ARGS
    else
      $SF -i -r .
    fi
  fi
else
  echo "swift-format not found in $TOOLCHAIN; skipping Swift files."
fi

# -------- Format web assets with Prettier --------
if command -v prettier >/dev/null 2>&1; then
  echo "Using Prettier: $(prettier --version)"

  # Detect repo root (for ignore paths & globs)
  if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
    REPO_ROOT="$(git rev-parse --show-toplevel)"
  else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"  # adjust if script lives elsewhere
  fi

  PRETTIER_ARGS=""
  # If there is no Prettier config, default to no semicolons
  has_cfg=false
  for cfg in .prettierrc .prettierrc.json .prettierrc.yml .prettierrc.yaml \
             .prettierrc.js prettier.config.js prettier.config.cjs prettier.config.mjs package.json
  do
    [[ -f "$REPO_ROOT/$cfg" ]] && { has_cfg=true; break; }
  done
  [[ $has_cfg == false ]] && PRETTIER_ARGS="--no-semi"

  # Merge .prettierignore + .prettier-ignore-extra into a combined ignore in REPO_ROOT
  COMBINED_IGNORE=""
  EXTRA_IGNORE="$REPO_ROOT/.prettier-ignore-extra"
  if [[ -f "$REPO_ROOT/.prettierignore" || -f "$EXTRA_IGNORE" ]]; then
    COMBINED_IGNORE="$REPO_ROOT/.prettierignore.combined.$$"
    TMPFILES+=("$COMBINED_IGNORE")

    # Clean inputs before concatenating
    if [[ -f "$REPO_ROOT/.prettierignore" ]]; then
      clean_ignore_file "$REPO_ROOT/.prettierignore" "$COMBINED_IGNORE"
    else
      : > "$COMBINED_IGNORE"
    fi
    if [[ -f "$EXTRA_IGNORE" ]]; then
      EXTRA_CLEAN="$REPO_ROOT/.prettier-ignore-extra.clean.$$"
      TMPFILES+=("$EXTRA_CLEAN")
      clean_ignore_file "$EXTRA_IGNORE" "$EXTRA_CLEAN"
      cat "$EXTRA_CLEAN" >> "$COMBINED_IGNORE"
    fi

    if [[ -s "$COMBINED_IGNORE" ]]; then
      PRETTIER_ARGS="$PRETTIER_ARGS --ignore-path $COMBINED_IGNORE"
      echo "Applying ignore patterns from $(basename "$COMBINED_IGNORE")"
    fi
  fi

  # Run Prettier from repo root using globs so ignore files are honored
  (
    cd "$REPO_ROOT" || exit 1
    # shellcheck disable=SC2086  # intentional word-splitting for PRETTIER_ARGS
    prettier --write --log-level warn $PRETTIER_ARGS "**/*.{js,jsx,ts,tsx,json,html,htm,css,md}"
  )
else
  echo "Prettier not found; skipping JS/HTML/CSS formatting."
  echo "Install with: npm install -g prettier"
fi

echo "Done."
