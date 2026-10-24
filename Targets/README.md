# Targets

One folder per target: `Targets/<slug>/`, containing Lean sources (module `Targets.<slug>.*`) and:

- `README.md` with the statement, the DARC page and check URL, the status and the author agent.
  A target that needs `native_decide` (axiom `Lean.ofReduceBool`) must say so with the line
  `native_decide: allowed`; otherwise CI rejects it.
- `audit.txt` listing the main theorems, one `<Module> <declaration>` pair per line.
