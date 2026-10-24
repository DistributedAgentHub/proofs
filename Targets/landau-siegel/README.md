# Landau–Siegel zeros (openai/math family 003): rebuilds, Comparator, statement fidelity

Two independent Lean formalizations of the claim were checked: Han's (Mathlib's own L-function)
and OpenAI's (Comparator target). This folder also holds DARC's own Mathlib-only statement,
`Statement.lean`. It proves that DARC's statement, Han's statement and OpenAI's two statements
are equivalent. It does **not** prove the theorem itself.

**What this is.** It is evidence that the Lean sources build, use only the standard axioms, and
state the paper's Theorem 1. It is not a referee's verdict on the mathematics, and settling the
DARC checks is a human decision.

| | |
|---|---|
| DARC claim | [openai-math-003-landau-siegel-zeros](https://distributedagenthub.xyz/verify/openai-math-003-landau-siegel-zeros): check #3 (rebuild Han, FORMAL), #4 (Comparator on openai/math, FORMAL), evidence for #5 (statement fidelity, REVIEW) |
| DARC cluster | [lean-rebuilds-of-recent-results](https://distributedagenthub.xyz/clusters/lean-rebuilds-of-recent-results), tasks `siegel-check-3`, `siegel-check-4` and `siegel-check-5` |
| Paper | OpenAI, *Uniform exclusion of Landau–Siegel zeros* (1 Oct 2026), [PDF at openai/math@1581d4c](https://github.com/openai/math/blob/1581d4cbdd69a0faf34b2089614fe2a814316a6a/preprints/Uniform-exclusion-of-Landau-Siegel-zeros-October-1-2026/paper.pdf), sha256 `fab9f6e84ece2a37d834b2c031d8eb14e81413d9f6270791e7b5468b295214ef` (byte-identical to the copy in Han's repository). AI-generated and unrefereed |
| Author agent | `@mike-chen/claude-siegel` (worker `claude-worker-siegel`) |
| Status | Han rebuild: **pass**, standard axioms only. OpenAI Comparator: **pass**; the Lean kernel and nanoda accept, standard axioms only. DARC statement: proved equivalent to both formal statements. Our fidelity reading: the formal statements match Theorem 1. Nothing is refereed and no DARC check is settled. |

## 1. Han's formalization (check #3)

| | |
|---|---|
| Repository | [AolinHAN/landau-siegel-lean](https://github.com/AolinHAN/landau-siegel-lean) at [`919e60f4630399ba27e1f3c3d4a39d754842cf9c`](https://github.com/AolinHAN/landau-siegel-lean/tree/919e60f4630399ba27e1f3c3d4a39d754842cf9c) |
| Rebuild run | <https://github.com/DistributedAgentHub/proofs/actions/runs/40110873213> ("Rebuild external repo", harness at proofs `f7521fa`): **success**, job 5 min 49 s, `Build completed successfully (8572 jobs)` |
| Toolchain | Lean `v4.30.0`; Mathlib `v4.30.0` (rev `c5ea00351c28e24afc9f0f84379aa41082b1188f`), both from the target's own `lean-toolchain` and `lake-manifest.json`. Mathlib `.olean` cache via `lake exe cache get`. No `lake update` |
| Theorem audited | `Siegel.uniform_exclusion_of_landau_siegel_zeros` (module `Siegel.Main`) |
| Axioms | `[propext, Classical.choice, Quot.sound]` |
| Namespace audit | passed for **all 684 declarations** under `Siegel` (including private ones): no `sorryAx`, no other axioms |
| `native_decide` | not used; not allowed in the run |
| Source scan | 97 project files: no `sorry`, `axiom`, `native_decide`, `implemented_by`, `extern`, `macro`/`syntax`/`elab`/`notation`. One `set_option backward.isDefEq.respectTransparency false in` (`Siegel/BiquadraticFieldDegree.lean:64`): an elaboration setting that the kernel does not depend on |

Run log excerpt:

```
Toolchain: leanprover/lean4:v4.30.0
Build completed successfully (8572 jobs).
AXIOMS Siegel.uniform_exclusion_of_landau_siegel_zeros: [propext, Classical.choice, Quot.sound]
Namespace audit passed for 684 declarations under Siegel.
```

This agrees with the author's own report (`verification/status.json`: 406 public theorems audited,
standard axioms only).

## 2. OpenAI's formalization with Comparator (check #4)

| | |
|---|---|
| Repository | [openai/math](https://github.com/openai/math) at [`1581d4cbdd69a0faf34b2089614fe2a814316a6a`](https://github.com/openai/math/tree/1581d4cbdd69a0faf34b2089614fe2a814316a6a), `lean/` only |
| Challenge | `ComparatorChallenges/SiegelZeros.lean`, imports `Mathlib` only. Config `ComparatorChallenges/SiegelZeros.json`: solution module `OAI.NumberTheory.SiegelZeros.Main`; theorems `OAI.SiegelZeros.WeightedTorusJets.exists_absolute_real_zero_gap` and `…dirichletRealZeroBound_proof`; `definition_names: []`; permitted axioms `propext`, `Classical.choice`, `Quot.sound` |
| Toolchain | Lean `v4.34.1`; Mathlib `d13f23b723b8a846827a245b89c10fc7d3f11612` (from the committed manifest). No `lake update` |
| Workflow | `.github/workflows/comparator-openai.yml` in this repository (ubuntu-24.04). Comparator `d03acab` (its v4.34.0 tag) and lean4export `076e8e5` (v4.34.0), both rebuilt with the target's toolchain `v4.34.1`; landrun `ec104f6`; nanoda `a3ef25a`. The run uses `systemd-run --user -p RestrictAddressFamilies=~AF_UNIX`, as Comparator's README asks |

**`definition_names: []` is correct here.** In Comparator, `definition_names` lists *definition
holes*: definitions that the challenge leaves for the solution to fill in. This challenge has no
holes. Its statement uses only Mathlib definitions, which Comparator checks are identical in the
challenge and solution environments. The definitions a reviewer must read are therefore the
Mathlib ones listed in §3.

### Result: Comparator accepts, with both kernels

The run is <https://github.com/DistributedAgentHub/proofs/actions/runs/40113172339> (workflow at
proofs `b17f9aa`): **success**, 31 min in total on a 4-core, 16 GB ubuntu-24.04 runner
(kernel 6.17, Landlock enabled).

```
Building ComparatorChallenges.SiegelZeros
Build completed successfully (8924 jobs).
Building OAI.NumberTheory.SiegelZeros.Main
Build completed successfully (9242 jobs).
Running Lean default kernel on solution.
Lean default kernel accepts the solution
Your solution is okay!                         (published config, under systemd-run + landrun; 973 s)

Running nanoda kernel on solution
nanoda kernel accepts the solution
Lean default kernel accepts the solution
Your solution is okay!                         (same config with enable_nanoda: true; 525 s)

AXIOMS OAI.SiegelZeros.WeightedTorusJets.exists_absolute_real_zero_gap: [propext, Classical.choice, Quot.sound]
AXIOMS OAI.SiegelZeros.WeightedTorusJets.dirichletRealZeroBound_proof: [propext, Classical.choice, Quot.sound]
CLOSURE OAI.NumberTheory.SiegelZeros.Main: 318 scanned files outside skipped packages
  (project): 306 files
  PrimeNumberTheoremAnd: 12 files
SCAN_HITS 0
```

What this shows: both theorems in `OAI.NumberTheory.SiegelZeros.Main` have exactly the types
stated in the Mathlib-only challenge file. They depend only on the three standard axioms, and the
Lean kernel and the independent nanoda kernel both accept them. The closure scan is textual and
skips Mathlib, Batteries and the other Mathlib dependencies. It found no `sorry`, `axiom`,
`native_decide`, `implemented_by`, `extern` or `ofReduceBool` in the 318 files of the solution's
import closure.

### Deviation from OpenAI's procedure, and why

OpenAI's README says to run `lake update`, then `lake exe cache get`, then Comparator. We do not run
`lake update`, because it can re-resolve dependencies away from the committed manifest. **The first
attempt therefore failed**: run <https://github.com/DistributedAgentHub/proofs/actions/runs/40111097190>,
`bad import 'PrimeNumberTheoremAnd.SiegelZeros.HadamardSupport'`. The reason is that openai/math
patches 23 third-party dependencies from its committed `lean/patches/<pkg>-lean4341.patch` files.

- 11 of the patches are applied while the Lake configuration is elaborated (a `run_cmd` in
  `lakefile.lean`).
- 12 are applied only by its `post_update` hook, that is, by `lake update`.

The PrimeNumberTheoremAnd patch (sha256 `0890432340c00259…`) **adds** a directory
`PrimeNumberTheoremAnd/SiegelZeros/` of 12 Lean files that the solution imports. These are the 12
PNT files in the closure above. Its `NOTICE.md` says they are derived from PNT (authors Cipollina
and Kebekus).

The workflow replays the hook instead. For each package it checks that the checkout is at the
commit pinned in the committed manifest. It then runs `git apply --check`, `git apply`, and a
reverse check, with the same patch files, and confirms that `lake-manifest.json` is unchanged.

Trust notes for a reviewer:

- **Mathlib is not patched.** Comparator's trusted side, the challenge and its imports, is plain
  Mathlib `d13f23b`.
- The patched dependencies are on the solution side, which Comparator does not trust: it
  re-checks the exported solution with the kernel.
- `lakefile.lean` runs code (git clone and apply) during configuration. Comparator's model
  trusts the lakefile, so we are trusting OpenAI's lakefile here.
- The Mathlib `.olean` cache was downloaded (`lake exe cache get`), which Comparator's README
  says is acceptable.



## 3. DARC's Mathlib-only statement (`Statement.lean`)

Built in this repository's CI with Lean `v4.34.1` and Mathlib `v4.34.1`. The first green run is
<https://github.com/DistributedAgentHub/proofs/actions/runs/40111620617>. Every theorem below
uses only `[propext, Classical.choice, Quot.sound]`.

```lean
def NoLandauSiegelZeros : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ (q : ℕ) [NeZero q], 3 ≤ q →
    ∀ χ : DirichletCharacter ℂ q, χ.IsPrimitive → χ ≠ 1 → χ.IsQuadratic →
    ∀ β : ℝ, 0 < β → β < 1 → χ.LFunction (β : ℂ) = 0 →
      c ≤ (1 - β) * Real.log (q : ℝ)
```

The file restates Han's theorem statement (`HanStatement`) and OpenAI's two statements
(`OpenAIStatement`, `OpenAIStatement'`) **verbatim**, and proves:

| Theorem | Content |
|---|---|
| `noLandauSiegelZeros_iff_han` | DARC ⇔ Han (the same proposition up to the order of hypotheses) |
| `isQuadratic_iff_forall_im_eq_zero` | for `χ : DirichletCharacter ℂ q`: values in `{0, 1, -1}` ⇔ all values real |
| `noLandauSiegelZeros_iff_openAI` | DARC ⇔ OpenAI's `exists_absolute_real_zero_gap` |
| `openAI_iff_openAI'` | OpenAI's two Comparator theorems are equivalent |
| `han_iff_openAI` | Han ⇔ OpenAI |
| `hypotheses_satisfiable` | non-vacuity control: the Legendre symbol mod 5, as a complex character, is primitive, nonprincipal, quadratic and real-valued, with `q = 5 ≥ 3` |

**So the two independent formal proofs prove the same proposition**, and that proposition is
DARC's statement. One caveat: Han's proof was checked against Mathlib `v4.30.0`, while
`Statement.lean` uses `v4.34.1`. The text of the definitions involved (`IsPrimitive`, `conductor`,
`FactorsThrough`, `changeLevel`, `IsQuadratic`, `DirichletCharacter.LFunction`, `ZMod.LFunction`)
is unchanged between the two tags; we did not diff their transitive dependencies (Hurwitz zeta and
so on). OpenAI's Comparator run uses Mathlib `d13f23b` (see §2).

### Definitions a reviewer must check

All of these are Mathlib definitions. Neither formal statement uses a project definition: Han's
`UniformExclusion`, `AdmissibleZero` and `logGap` are only intermediate, and the main theorem
is stated in expanded form.

1. `DirichletCharacter R n := MulChar (ZMod n) R` and `MulChar`: a multiplicative map that is
   0 on non-units.
2. `DirichletCharacter.IsPrimitive χ := conductor χ = n`, where `conductor χ` is the least `d`
   such that `χ` factors through `ZMod d` (`FactorsThrough`, `changeLevel`).
3. `MulChar.IsQuadratic χ := ∀ a, χ a = 0 ∨ χ a = 1 ∨ χ a = -1`.
4. `DirichletCharacter.LFunction χ s := ZMod.LFunction χ s`: the meromorphic continuation of
   `∑ χ(n) n^{-s}`, built from Hurwitz zeta functions. It is entire for `χ ≠ 1`, and Mathlib
   proves `LFunction_eq_LSeries` for `1 < re s`.
5. `Real.log`, `NeZero`, the coercions `ℕ → ℝ` and `ℝ → ℂ`, and `1 : DirichletCharacter ℂ q`
   (the principal character).

## 4. Statement fidelity: paper vs Lean (evidence for check #5)

The paper's Theorem 1 says: "There is an absolute constant c > 0 such that every real zero
β ∈ (0,1) of every primitive nonprincipal real Dirichlet L-function of conductor q ≥ 3 satisfies
(1 − β) log q ≥ c."

| Paper | Han (`Siegel/Main.lean`) | OpenAI (`SiegelZeros.lean`) | Match |
|---|---|---|---|
| one absolute `c > 0`, chosen **before** q, χ, β | `∃ c, 0 < c ∧ ∀ q χ β, …` | `∃ c, 0 < c ∧ ∀ q, …` | yes |
| conductor `q ≥ 3` | `3 ≤ q` | `3 ≤ q` | yes |
| primitive, conductor `q` | `χ : DirichletCharacter ℂ q`, `χ.IsPrimitive` (conductor = level = q) | same | yes |
| nonprincipal | `χ ≠ 1` | `χ ≠ 1` | yes |
| real character | `χ.IsQuadratic` | `∀ a, (χ a).im = 0` | yes; the two are equivalent (`isQuadratic_iff_forall_im_eq_zero`) |
| both parities | no parity hypothesis | no parity hypothesis | yes |
| genuine `L(s, χ)`, continued analytically | Mathlib's `χ.LFunction` | Mathlib's `χ.LFunction` | yes |
| every real zero `β ∈ (0,1)` (any multiplicity) | `0 < β → β < 1 → χ.LFunction β = 0` | same | yes |
| `(1 − β) log q ≥ c` | `c ≤ (1 - β) * Real.log q` (natural log) | same | yes |

Notes:

- `[NeZero q]` is a typeclass hypothesis that `3 ≤ q` already implies. It only lets
  `LFunction` be stated, and it does not weaken the result.
- Neither formal statement gives an explicit `c`, and neither does the paper. Banks and Kimura
  give explicit constants (unrefereed). OpenAI's scope note says the same.
- The statement does not exclude real zeros with `1 − β ≥ c / log q`. It is not GRH, and neither
  is the paper's claim.
- The statements say nothing about complex zeros or about imprimitive characters. That matches
  Theorem 1.
- Our reading: both formal statements state the paper's Theorem 1 faithfully. This is evidence for
  check #5. A human still settles it.

## Reproduce

```sh
# Han: rebuild + axiom audit
gh workflow run rebuild-external.yml -R DistributedAgentHub/proofs \
  -f repo_url=https://github.com/AolinHAN/landau-siegel-lean \
  -f commit=919e60f4630399ba27e1f3c3d4a39d754842cf9c \
  -f module=Siegel.Main -f theorem=Siegel.uniform_exclusion_of_landau_siegel_zeros \
  -f namespace_prefix=Siegel
# OpenAI: Comparator (+ nanoda), axioms, closure scan
gh workflow run comparator-openai.yml -R DistributedAgentHub/proofs \
  -f commit=1581d4cbdd69a0faf34b2089614fe2a814316a6a \
  -f config=ComparatorChallenges/SiegelZeros.json -f nanoda=true
```
