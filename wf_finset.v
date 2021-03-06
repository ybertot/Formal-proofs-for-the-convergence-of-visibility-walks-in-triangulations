From mathcomp Require Import all_ssreflect.
From Equations Require Import Equations.
Require Import Arith.
Import Wellfounded.

Section wf_rel.

Variable T : finType.

Variable rel : T -> T -> bool.

Hypothesis rel_trans :
  forall (t1 t2 t3 : T), rel t1 t2 -> rel t2 t3 -> rel t1 t3.

Hypothesis rel_anti_refl :
  forall (t : T), ~ rel t t.

Definition rel_inv (t1 t2 : T) := rel t2 t1.
 
Definition subSetRel (t : T) := finset (rel_inv t).

Lemma decrease_card :
  forall (t1 t2 : T),
  t2 \in subSetRel t1 -> #|subSetRel t2| < #|subSetRel t1|.
Proof.
move => t1 t2 h.
rewrite /subSetRel in_set /rel_inv in h.
have proper : subSetRel t2 \proper subSetRel t1.
  have subset : subSetRel t2 \subset subSetRel t1.
    apply /subsetP.
    rewrite /subSetRel /sub_mem => x.
    rewrite !in_set /rel_inv => in1.
    by apply: (rel_trans x t2 t1).
  have diff : subSetRel t2 != subSetRel t1.
    rewrite eqEsubset.
    apply /nandP.
    rewrite subset /=.
    apply /orP.
    rewrite /=.
    apply /subsetPn.
    exists t2.
      by rewrite in_set.
    rewrite in_set /rel_inv.
    apply/negP.
    by apply: rel_anti_refl.
  by rewrite properEneq subset diff.
rewrite properEcard in proper.
move/andP: proper.
move => proper.
destruct proper.
apply: H0.
Qed.

Definition f (t : T) : nat := #|subSetRel t|.

Definition rel_in_nat (t1 t2 : T) :=  lt (f t1) (f t2).

Lemma rel_to_nat : Relation_Definitions.inclusion T rel rel_in_nat.
Proof.
rewrite /Relation_Definitions.inclusion.
move => t1 t2 h.
rewrite /rel_in_nat /f.
apply /ltP.
apply: decrease_card.
by rewrite in_set /rel_inv.
Qed.

Lemma wf_rel_in_nat : well_founded rel_in_nat.
Proof.
rewrite /rel_in_nat.
apply: (wf_inverse_image T nat lt f).
by apply: lt_wf.
Qed.

Lemma wf_rel : well_founded rel.
Proof.
apply: wf_incl.
apply: rel_to_nat.
by apply : wf_rel_in_nat.
Qed.

End wf_rel.