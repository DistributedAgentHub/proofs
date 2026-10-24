#!/usr/bin/env bash
# Audit every Targets/*/audit.txt. native_decide is allowed only if the target README says
# "native_decide: allowed".
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
fail=0
if grep -rn --include=*.lean -w sorry "$root/Targets" | grep -v '^\s*--'; then
  echo "::error::sorry found in Targets"; fail=1
fi
for f in "$root"/Targets/*/audit.txt; do
  t=$(dirname "$f"); native=0
  grep -qi '^[-* ]*\**native_decide:\**[[:space:]]*allowed' "$t/README.md" && native=1
  while read -r mod decl _; do
    [[ -z "${mod:-}" || "$mod" == \#* ]] && continue
    echo "== $(basename "$t"): $decl (native_decide allowed=$native)"
    "$root/scripts/axiom_audit.sh" "$root" "$mod" "$decl" "$native" || fail=1
  done < "$f"
done
exit $fail
