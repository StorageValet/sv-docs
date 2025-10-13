#!/usr/bin/env bash
set -euo pipefail

ROOT="$HOME"
CODE="$ROOT/code"
DOCS="$CODE/sv-docs"
RUNBOOKS="$DOCS/runbooks"
OPS="$RUNBOOKS/ops"

mkdir -p "$OPS"

# Files currently in ~/code to relocate
DOC_LIST=(
  "PHASE_0.6_GATES_v3.1.md"
  "VERCEL_SETUP_COMPLETE_2025-10-13.md"
  "secrets_needed.md"
  "stripe_test_setup.md"
)
SCRIPT_LIST=(
  "smoke-tests.sh"
  "test_stripe_webhook.sh"
  "consolidate-repos.sh"
  "sanitize-filenames.sh"
)

# Move docs into runbooks/, scripts into runbooks/ops/
for f in "${DOC_LIST[@]}";   do [ -e "$CODE/$f" ] && mv "$CODE/$f" "$RUNBOOKS/$f" || true; done
for f in "${SCRIPT_LIST[@]}";do [ -e "$CODE/$f" ] && mv "$CODE/$f" "$OPS/$f"      || true; done

# Touch README links (idempotent)
if [ -d "$DOCS/.git" ]; then
  cd "$DOCS"
  if ! grep -q "### Runbooks index" README.md 2>/dev/null; then
    cat >> README.md <<'MD'

---

### Runbooks index
- **Gate results:** `runbooks/PHASE_0.6_GATES_v3.1.md`
- **Vercel setup status:** `runbooks/VERCEL_SETUP_COMPLETE_2025-10-13.md`
- **Secrets checklist:** `runbooks/secrets_needed.md`
- **Stripe test setup:** `runbooks/stripe_test_setup.md`
- **Ops scripts:** `runbooks/ops/` (consolidation, sanitization, smoke tests)
MD
  fi

  git add -A
  git commit -m "Docs: move remaining runbooks/scripts into sv-docs (ops tidy)" || true
  git push || true
fi

# Sanity check: show any remaining md/sh in ~/code root
echo
echo "=== Residual *.md/*.sh in ~/code (should be 0 lines) ==="
ls -1 "$CODE"/*.{md,sh} 2>/dev/null || echo "(none)"
echo "Done."
