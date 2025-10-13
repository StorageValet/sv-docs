#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME"
CODE="$ROOT/code"
ARCH="$ROOT/archive"
PLANNING="$ROOT/OCT-LAUNCH-FINAL"
DOCS="$CODE/sv-docs"

mkdir -p "$CODE" "$ARCH" "$DOCS/runbooks"

find_doc() { find "$ROOT" -maxdepth 5 -type f -name "$1" 2>/dev/null | head -n1; }

IMP="$(find_doc 'SV_Implementation_Plan_FINAL_v3.1_2025-10-10.md')"
CHK="$(find_doc 'FINAL_VALIDATION_CHECKLIST_v3.1.md')"
DEP="$(find_doc 'Deployment_Instructions_v3.1.md')"
GNG="$(find_doc 'LINE_IN_THE_SAND_Go-NoGo_v3.1.md')"
BIZ="$(find_doc 'Business_Context_and_Requirements_v3.1.md')"

# Move five source-of-truth docs into sv-docs
for f in "$IMP" "$CHK" "$DEP" "$GNG" "$BIZ"; do
  [ -n "${f:-}" ] || continue
  [ -e "$f" ] || continue
  base="$(basename "$f")"
  [ -e "$DOCS/$base" ] || mv "$f" "$DOCS/$base"
done

# Move runbooks sitting in code/ root into sv-docs/runbooks
shopt -s nullglob
for f in "$CODE"/{*_GUIDE*.md,*TEST_PLAN*.md,*_STATUS_*.md,*.RUNBOOK.md,BUILD_SUMMARY*.md,DEPLOYMENT_GUIDE*.md} \
         "$CODE"/{check_*webhook*.sh,set_*secrets*_*.sh,vercel_*_*.sh,set_vercel_env_staging.sh,set_supabase_secrets_staging.sh,smoke_tests.sh}; do
  mv "$f" "$DOCS/runbooks/" || true
done
shopt -u nullglob

# Archive planning folder
if [ -d "$PLANNING" ] && [ "$(ls -A "$PLANNING" | wc -l)" -gt 0 ]; then
  ts="$(date +%Y-%m-%d_%H-%M)"
  mv "$PLANNING" "$ARCH/oct-launch-final_$ts"
fi

# Add README pointers in code repos
add_pointer() {
  local repo="$1"
  [ -d "$repo" ] || return 0
  cd "$repo"
  if [ ! -f README.md ] || ! grep -qi 'sv-docs' README.md; then
    cat >> README.md <<'MD'

---

### Project docs
Core specs & runbooks: **https://github.com/mystoragevalet/sv-docs**

- Implementation Plan v3.1
- Final Validation Checklist v3.1
- Deployment Instructions v3.1
- Go–NoGo (Line in the Sand) v3.1
- Business Context & Requirements v3.1
- Runbooks (webhook tests, env setup, smoke tests)
MD
  fi
}
add_pointer "$CODE/sv-db"
add_pointer "$CODE/sv-edge"
add_pointer "$CODE/sv-portal"

# Init/push helper
push_repo() {
  local path="$1" repo="$2"
  [ -d "$path" ] || return 0
  cd "$path"
  [ -d .git ] || git init
  git add -A
  git commit -m "Phase 0.6 consolidation (docs/runbooks/archives)" || true
  git branch -M main
  if ! git remote get-url origin >/dev/null 2>&1; then
    gh repo create "mystoragevalet/$repo" --private --source=. --push || true
  else
    git push -u origin main || true
  fi
  git tag -f phase-0.6-consolidated
  git push -f --tags || true
}

# Push docs first, then code repos
push_repo "$DOCS" "sv-docs"
push_repo "$CODE/sv-db" "sv-db"
push_repo "$CODE/sv-edge" "sv-edge"
push_repo "$CODE/sv-portal" "sv-portal"

echo
echo "=== FINAL LAYOUT ==="
( cd "$ROOT" && /usr/bin/find code -maxdepth 2 -type d -print | sed 's/^/~\//' )
echo "Docs: $DOCS"
echo "Archive: $ARCH"
echo "Done."
