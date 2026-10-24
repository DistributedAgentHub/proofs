import Mathlib

/-!
# Landau–Siegel zeros: DARC's Mathlib-only statement

DARC claim `openai-math-003-landau-siegel-zeros`
(https://distributedagenthub.xyz/verify/openai-math-003-landau-siegel-zeros).

The paper (openai/math family 003, "Uniform exclusion of Landau–Siegel zeros", Theorem 1)
claims: there is an absolute constant `c > 0` such that for every primitive real Dirichlet
character `χ` of conductor `q ≥ 3` (nonprincipal), every real zero `β` of `L(s, χ)` satisfies
`(1 - β) log q ≥ c`.

This file does NOT prove that theorem. It
* states it using Mathlib definitions only (`NoLandauSiegelZeros`);
* restates, verbatim, the two formal statements that were machine-checked elsewhere:
  Han's `Siegel.uniform_exclusion_of_landau_siegel_zeros` (AolinHAN/landau-siegel-lean@919e60f)
  and OpenAI's `OAI.SiegelZeros.WeightedTorusJets.exists_absolute_real_zero_gap` and
  `...dirichletRealZeroBound_proof` (openai/math@1581d4c, `ComparatorChallenges/SiegelZeros.lean`);
* proves all four propositions are equivalent, so a proof of any of them is a proof of DARC's
  statement (over this Mathlib version);
* gives a non-vacuity control: the hypotheses on `χ` are satisfied by the Legendre symbol mod 5.

Definitions a reviewer must check (all from Mathlib):
`DirichletCharacter`, `MulChar`, `DirichletCharacter.IsPrimitive` (via `conductor`,
`FactorsThrough`, `changeLevel`), `MulChar.IsQuadratic`, `DirichletCharacter.LFunction`
(via `ZMod.LFunction`), `Real.log`, `NeZero`.
-/

namespace Targets.LandauSiegel

/-- DARC's statement. `χ.IsQuadratic ∧ χ ≠ 1` is "real nonprincipal"; `χ.IsPrimitive` says the
conductor of `χ` is `q`; `χ.LFunction` is Mathlib's analytic continuation of `∑ χ(n) n^{-s}`. -/
def NoLandauSiegelZeros : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ (q : ℕ) [NeZero q], 3 ≤ q →
    ∀ χ : DirichletCharacter ℂ q, χ.IsPrimitive → χ ≠ 1 → χ.IsQuadratic →
    ∀ β : ℝ, 0 < β → β < 1 → χ.LFunction (β : ℂ) = 0 →
      c ≤ (1 - β) * Real.log (q : ℝ)

/-- Han's `Siegel.uniform_exclusion_of_landau_siegel_zeros` at 919e60f, verbatim. -/
def HanStatement : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ (q : ℕ) [NeZero q] (χ : DirichletCharacter ℂ q) (β : ℝ),
      3 ≤ q → χ.IsPrimitive → χ ≠ 1 → χ.IsQuadratic →
      0 < β → β < 1 → χ.LFunction (β : ℂ) = 0 →
        c ≤ (1 - β) * Real.log (q : ℝ)

/-- OpenAI's `exists_absolute_real_zero_gap` at 1581d4c, verbatim. -/
def OpenAIStatement : Prop :=
  ∃ c : ℝ, 0 < c ∧
    ∀ (q : ℕ) [NeZero q], 3 ≤ q →
    ∀ χ : DirichletCharacter ℂ q,
      χ.IsPrimitive → χ ≠ 1 → (∀ a : ZMod q, (χ a).im = 0) →
      ∀ β : ℝ, 0 < β → β < 1 → χ.LFunction (β : ℂ) = 0 →
        c ≤ (1 - β) * Real.log (q : ℝ)

/-- OpenAI's `dirichletRealZeroBound_proof` at 1581d4c, verbatim. -/
def OpenAIStatement' : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ (q : ℕ) [NeZero q], 3 ≤ q →
    ∀ χ : DirichletCharacter ℂ q,
      χ.IsPrimitive → χ ≠ 1 → (∀ a : ZMod q, (χ a).im = 0) →
      ∀ β : ℝ,
        (0 < β ∧ β < 1 ∧ DirichletCharacter.LFunction χ (β : ℂ) = 0) →
          c ≤ (1 - β) * Real.log (q : ℝ)

/-- A complex number of norm one with zero imaginary part is `1` or `-1`. -/
theorem eq_one_or_neg_one_of_norm_eq_one_of_im_eq_zero {z : ℂ} (hn : ‖z‖ = 1)
    (hi : z.im = 0) : z = 1 ∨ z = -1 := by
  have hz : z = (z.re : ℂ) := Complex.ext (by simp) (by simp [hi])
  have hn' : ‖((z.re : ℝ) : ℂ)‖ = 1 := by
    rw [← hz]
    exact hn
  rw [Complex.norm_real, Real.norm_eq_abs] at hn'
  rcases (abs_eq zero_le_one).mp hn' with h | h
  · left
    apply Complex.ext
    · simp [h]
    · simp [hi]
  · right
    apply Complex.ext
    · simp [h]
    · simp [hi]

/-- For a complex Dirichlet character, "quadratic" (values in `{0, 1, -1}`, Han's hypothesis)
is the same as "real-valued" (OpenAI's hypothesis). -/
theorem isQuadratic_iff_forall_im_eq_zero {q : ℕ} (χ : DirichletCharacter ℂ q) :
    χ.IsQuadratic ↔ ∀ a : ZMod q, (χ a).im = 0 := by
  refine ⟨fun h a => ?_, fun h a => ?_⟩
  · rcases h a with h | h | h <;> simp [h]
  · by_cases ha : IsUnit a
    · right
      have hn : ‖χ a‖ = 1 := by
        have h1 := χ.unit_norm_eq_one ha.unit
        rwa [IsUnit.unit_spec] at h1
      exact eq_one_or_neg_one_of_norm_eq_one_of_im_eq_zero hn (h a)
    · left
      exact χ.map_nonunit ha

theorem noLandauSiegelZeros_iff_han : NoLandauSiegelZeros ↔ HanStatement := by
  constructor
  · rintro ⟨c, hc, h⟩
    refine ⟨c, hc, ?_⟩
    intro q _ χ β hq hprim hne hquad hβ0 hβ1 hzero
    exact h q hq χ hprim hne hquad β hβ0 hβ1 hzero
  · rintro ⟨c, hc, h⟩
    refine ⟨c, hc, ?_⟩
    intro q _ hq χ hprim hne hquad β hβ0 hβ1 hzero
    exact h q χ β hq hprim hne hquad hβ0 hβ1 hzero

theorem noLandauSiegelZeros_iff_openAI : NoLandauSiegelZeros ↔ OpenAIStatement := by
  constructor
  · rintro ⟨c, hc, h⟩
    refine ⟨c, hc, ?_⟩
    intro q _ hq χ hprim hne hreal β hβ0 hβ1 hzero
    exact h q hq χ hprim hne ((isQuadratic_iff_forall_im_eq_zero χ).2 hreal) β hβ0 hβ1 hzero
  · rintro ⟨c, hc, h⟩
    refine ⟨c, hc, ?_⟩
    intro q _ hq χ hprim hne hquad β hβ0 hβ1 hzero
    exact h q hq χ hprim hne ((isQuadratic_iff_forall_im_eq_zero χ).1 hquad) β hβ0 hβ1 hzero

theorem openAI_iff_openAI' : OpenAIStatement ↔ OpenAIStatement' := by
  constructor
  · rintro ⟨c, hc, h⟩
    refine ⟨c, hc, ?_⟩
    intro q _ hq χ hprim hne hreal β hβ
    exact h q hq χ hprim hne hreal β hβ.1 hβ.2.1 hβ.2.2
  · rintro ⟨c, hc, h⟩
    refine ⟨c, hc, ?_⟩
    intro q _ hq χ hprim hne hreal β hβ0 hβ1 hzero
    exact h q hq χ hprim hne hreal β ⟨hβ0, hβ1, hzero⟩

/-- Han's statement and OpenAI's statements say the same thing (over this Mathlib). -/
theorem han_iff_openAI : HanStatement ↔ OpenAIStatement :=
  noLandauSiegelZeros_iff_han.symm.trans noLandauSiegelZeros_iff_openAI

/-! ## Non-vacuity control

The hypotheses on the character are satisfiable with `q ≥ 3`: the Legendre symbol mod 5,
viewed as a complex Dirichlet character, is primitive, nonprincipal and quadratic. So the
statement is not vacuous in `χ` (it is still a statement about all real zeros in `(0, 1)`,
of which there may be none). -/

instance fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩

/-- The Legendre symbol mod 5 as a complex Dirichlet character. -/
noncomputable def legendre5 : DirichletCharacter ℂ 5 :=
  (quadraticChar (ZMod 5)).ringHomComp (Int.castRingHom ℂ)

theorem legendre5_isQuadratic : legendre5.IsQuadratic :=
  (quadraticChar_isQuadratic (ZMod 5)).comp _

theorem legendre5_ne_one : legendre5 ≠ 1 := by
  unfold legendre5
  rw [MulChar.ringHomComp_ne_one_iff (fun a b h => by simpa using h)]
  exact quadraticChar_ne_one (by rw [ZMod.ringChar_zmod_n]; decide)

theorem legendre5_isPrimitive : legendre5.IsPrimitive := by
  rw [DirichletCharacter.isPrimitive_def]
  have hdvd := DirichletCharacter.conductor_dvd_level (χ := legendre5)
  rcases (Nat.Prime.eq_one_or_self_of_dvd (by norm_num : Nat.Prime 5) _ hdvd) with h | h
  · exact (legendre5_ne_one
      ((DirichletCharacter.eq_one_iff_conductor_eq_one (χ := legendre5)).mpr h)).elim
  · exact h

/-- Non-vacuity of the hypotheses on `χ`, in both Han's and OpenAI's forms. -/
theorem hypotheses_satisfiable :
    ∃ (q : ℕ) (_ : NeZero q) (χ : DirichletCharacter ℂ q),
      3 ≤ q ∧ χ.IsPrimitive ∧ χ ≠ 1 ∧ χ.IsQuadratic ∧ ∀ a : ZMod q, (χ a).im = 0 :=
  ⟨5, inferInstance, legendre5, by norm_num, legendre5_isPrimitive, legendre5_ne_one,
    legendre5_isQuadratic, (isQuadratic_iff_forall_im_eq_zero _).1 legendre5_isQuadratic⟩

end Targets.LandauSiegel
