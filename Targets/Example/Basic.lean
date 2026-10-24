import Mathlib.Tactic

namespace Targets.Example

/-- Trivial lemma that gives CI something to build and audit. -/
theorem add_comm_example (a b : ℕ) : a + b = b + a := by
  omega

end Targets.Example
