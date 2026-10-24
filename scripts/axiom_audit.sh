#!/usr/bin/env bash
# Usage: axiom_audit.sh <lake-project-dir> <Module> <Decl> [allow_native_decide(0|1)] [namespace-prefix]
# Prints the axioms of <Decl>. Fails on anything beyond propext, Classical.choice, Quot.sound
# (plus Lean.ofReduceBool when allowed), and on sorryAx. With a namespace prefix, every
# declaration under it (including private ones) is audited too.
set -euo pipefail
dir=$1; module=$2; decl=$3; native=${4:-0}; prefix=${5:-}
tmp=$(mktemp -d)
cat > "$tmp/Audit.lean" <<LEAN
import $module
import Lean.Util.CollectAxioms
open Lean Elab Command in
run_cmd do
  let env ← getEnv
  let allowed : Array Name := #[\`propext, \`Classical.choice, \`Quot.sound] ++
    (if $native == 1 then #[\`Lean.ofReduceBool] else #[])
  let main := \`$decl
  unless env.contains main do throwError "declaration {main} not found"
  let axs ← collectAxioms main
  logInfo m!"AXIOMS {main}: {axs.toList}"
  for ax in axs do
    unless allowed.contains ax do throwError "{main} depends on disallowed axiom {ax}"
  let prefixStr := "$prefix"
  if prefixStr != "" then
    let mut count : Nat := 0
    for (n, _) in env.constants.toList do
      if n.toString.startsWith prefixStr || n.toString.startsWith ("_private." ++ prefixStr) then
        for ax in ← collectAxioms n do
          unless allowed.contains ax do throwError "{n} depends on disallowed axiom {ax}"
        count := count + 1
    logInfo m!"Namespace audit passed for {count} declarations under {prefixStr}."
LEAN
# Escape fix: heredoc turned \` into a plain backtick.
(cd "$dir" && lake env lean "$tmp/Audit.lean") | tee "$tmp/out.txt"
grep -q "AXIOMS" "$tmp/out.txt"
rm -rf "$tmp"
