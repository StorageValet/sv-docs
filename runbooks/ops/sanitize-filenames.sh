#!/usr/bin/env bash
set -euo pipefail

# === Settings (Option B: scan planning folder too) ===
ROOT="$HOME"
REPOS=("$ROOT/code/sv-db" "$ROOT/code/sv-edge" "$ROOT/code/sv-portal" "$ROOT/code/sv-docs")
ALSO_CHECK=("$ROOT/OCT-LAUNCH-FINAL" "$ROOT/archive")  # include planning + archive
SCRUB_HEADINGS="false"   # set to "true" if you also want to remove emojis from Markdown headings

# === Helpers ===
is_repo() { [ -d "$1/.git" ]; }
ascii_clean() {
  # remove emoji/non-ASCII; collapse spaces; trim
  python3 - "$1" <<'PY'
import os, sys, re, unicodedata
p = sys.argv[1]
b = os.path.basename(p); d = os.path.dirname(p)
n = unicodedata.normalize('NFC', b)
clean = ''.join(ch for ch in n if ord(ch) < 128)
clean = re.sub(r'\s+', ' ', clean).strip() or "file"
print(os.path.join(d, clean))
PY
}

scan_paths() {
  local path="$1"
  [ -d "$path" ] || return 0
  LC_ALL=C find "$path" -depth -print0 | while IFS= read -r -d '' p; do
    # flag if contains non-ASCII
    if ! LC_ALL=C printf '%s' "$p" | grep -q '^[ -~]*$'; then
      printf '%s\0' "$p"
    fi
  done
}

rename_path() {
  local p="$1" repo="$2"
  local q; q="$(ascii_clean "$p")"
  [ "$p" = "$q" ] && return 0
  mkdir -p "$(dirname "$q")"
  if [ "$repo" = "true" ]; then
    # If tracked, prefer git mv; else fall back to mv
    top="$(git -C "$p" rev-parse --show-toplevel 2>/dev/null || true)"
    if [ -n "$top" ]; then
      rel_from="${p#$top/}"; rel_to="${q#$top/}"
      (cd "$top" && git mv -k -- "$rel_from" "$rel_to") || mv -- "$p" "$q"
    else
      mv -- "$p" "$q"
    fi
  else
    mv -- "$p" "$q"
  fi
  echo "RENAMED: $p -> $q"
}

scrub_md_headings() {
  local root="$1"
  [ "$SCRUB_HEADINGS" != "true" ] && return 0
  find "$root" -type f -name "*.md" -print0 | while IFS= read -r -d '' f; do
    python3 - "$f" <<'PY'
import sys, re
p = sys.argv[1]
with open(p, 'r', encoding='utf-8', errors='ignore') as fh:
    txt = fh.read()
def deemoji(line):
    # e.g., "## 📦 Title" -> "## Title"
    return re.sub(r'^(#{1,6}\s+)[^\w#\s-]+(\s*)', r'\1', line)
new = '\n'.join(deemoji(l) for l in txt.splitlines())
if new != txt:
    with open(p, 'w', encoding='utf-8') as fh:
        fh.write(new)
PY
    echo "SCRUBBED HEADINGS: $f"
  done
}

# === DRY RUN REPORT ===
echo "=== DRY RUN: non-ASCII filenames in repos ==="
for r in "${REPOS[@]}"; do
  [ -d "$r" ] || continue
  echo "--- $r"
  scan_paths "$r" | xargs -0 -I{} echo "FOUND: {}" || true
done

echo "=== DRY RUN: non-ASCII filenames outside repos ==="
for p in "${ALSO_CHECK[@]}"; do
  [ -d "$p" ] || continue
  echo "--- $p"
  scan_paths "$p" | xargs -0 -I{} echo "FOUND: {}" || true
done

echo
echo "Proceeding to rename any non-ASCII paths to ASCII-only…"

# === RENAME IN REPOS (git-aware) ===
for r in "${REPOS[@]}"; do
  [ -d "$r" ] || continue
  echo "--- RENAMING UNDER REPO: $r"
  scan_paths "$r" | while IFS= read -r -d '' p; do
    rename_path "$p" "true"
  done
  # Commit renames if any
  if is_repo "$r"; then
    ( cd "$r"
      if ! git diff --quiet --cached || ! git diff --quiet; then
        git add -A
        git commit -m "Chore: remove emojis/non-ASCII from filenames"
        git push || true
      fi
    )
  fi
done

# === RENAME OUTSIDE REPOS (plain mv) ===
for p in "${ALSO_CHECK[@]}"; do
  [ -d "$p" ] || continue
  echo "--- RENAMING UNDER NON-REPO: $p"
  scan_paths "$p" | while IFS= read -r -d '' path; do
    rename_path "$path" "false"
  done
done

# === OPTIONAL: scrub Markdown headings of emoji (content, not filenames) ===
for r in "${REPOS[@]}"; do
  [ -d "$r" ] || continue
  scrub_md_headings "$r"
done

echo "Done. Filenames are ASCII-only. (Content unchanged unless SCRUB_HEADINGS=true.)"
