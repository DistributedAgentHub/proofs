#!/usr/bin/env python3
"""Scan the import closure of a Lean module for escape hatches.

Usage: closure_scan.py <lake-project-dir> <Module> [--skip-package NAME ...]

Resolves imports against the project's own sources and every package in
.lake/packages (Mathlib, Batteries and the core toolchain are skipped by default),
then prints every line that mentions sorry, native_decide, axiom declarations,
implemented_by, extern, Lean.ofReduceBool, or debug.skipKernelTC.
The kernel-level answer is `#print axioms`; this is a textual cross-check.
"""
import os
import re
import sys

root = sys.argv[1]
start = sys.argv[2]
skip = {"mathlib", "batteries", "aesop", "Qq", "proofwidgets", "importGraph",
        "LeanSearchClient", "plausible", "Cli"}
args = sys.argv[3:]
while args:
    if args[0] == "--skip-package" and len(args) > 1:
        skip.add(args[1]); args = args[2:]
    else:
        args = args[1:]

roots = [root]
pkgdir = os.path.join(root, ".lake", "packages")
if os.path.isdir(pkgdir):
    for p in sorted(os.listdir(pkgdir)):
        roots.append(os.path.join(pkgdir, p))


def find(mod):
    rel = mod.replace(".", os.sep) + ".lean"
    for r in roots:
        f = os.path.join(r, rel)
        if os.path.isfile(f):
            return r, f
    return None, None


imp_re = re.compile(r"^\s*(?:public\s+)?(?:meta\s+)?import\s+(?:all\s+)?([\w.«»']+)")
pat = re.compile(r"\bsorry\b|native_decide|^\s*(?:private\s+|protected\s+)?axiom\s|"
                 r"implemented_by|@\[\s*extern|ofReduceBool|skipKernelTC|decide\s*\+\s*kernel")

seen, order, stack = set(), [], [start]
unresolved = set()
while stack:
    m = stack.pop()
    if m in seen:
        continue
    seen.add(m)
    r, f = find(m)
    if f is None:
        unresolved.add(m.split(".")[0])
        continue
    pkg = os.path.basename(r) if r != root else "(project)"
    if pkg in skip:
        continue
    order.append((pkg, m, f))
    with open(f, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            mm = imp_re.match(line)
            if mm:
                stack.append(mm.group(1))

by_pkg = {}
for pkg, _, _ in order:
    by_pkg[pkg] = by_pkg.get(pkg, 0) + 1
print(f"CLOSURE {start}: {len(order)} scanned files outside skipped packages")
for k, v in sorted(by_pkg.items()):
    print(f"  {k}: {v} files")
print("  unresolved roots (toolchain/core): " + ", ".join(sorted(unresolved)))
hits = 0
for pkg, m, f in sorted(order, key=lambda t: t[1]):
    in_block = 0
    with open(f, encoding="utf-8", errors="replace") as fh:
        for i, line in enumerate(fh, 1):
            code = line
            # crude comment stripping: block comments /- -/ and line comments --
            if in_block:
                if "-/" in code:
                    in_block -= 1
                    code = code.split("-/", 1)[1]
                else:
                    continue
            if "/-" in code and "-/" not in code.split("/-", 1)[1]:
                in_block += 1
                code = code.split("/-", 1)[0]
            code = re.sub(r"/-.*?-/", "", code)
            code = code.split("--", 1)[0]
            if pat.search(code):
                hits += 1
                print(f"HIT {pkg} {m}:{i}: {line.rstrip()}")
print(f"SCAN_HITS {hits}")
