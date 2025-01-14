(herald goals)

(comment "CPSA 4.3.0")
(comment "All input read from tst/goals.scm")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n1 n2 text) (b a name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (non-orig (privk b))
  (uniq-orig n1)
  (goals
    (forall ((b name) (n1 text) (z0 strd))
      (implies
        (and (p "init" z0 3) (p "init" "n1" z0 n1) (p "init" "b" z0 b)
          (non (privk b)) (uniq n1))
        (exists ((z1 strd))
          (and (p "resp" z1 2) (p "resp" "b" z1 b))))))
  (comment "Initiator point of view"
    "Authentication goal: agreement on name b")
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 0)
  (unrealized (0 1))
  (origs (n1 (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 n2-0 text) (b a name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk b))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (0 1)
    (enc n1 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 1)
  (parent 0)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0) ((b b) (n1 n1) (a a) (n2 n2))))
  (origs (n1 (0 0))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n1 n2 text) (b a name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (non-orig (privk b))
  (uniq-orig n1)
  (goals
    (forall ((b name) (n1 text) (z0 strd))
      (implies
        (and (p "init" z0 3) (p "init" "n1" z0 n1) (p "init" "b" z0 b)
          (non (privk b)) (uniq n1))
        (exists ((z1 strd))
          (and (p "resp" z1 2) (p "resp" "b" z1 b) (prec z1 1 z0 2))))))
  (comment "Prec example")
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 2)
  (unrealized (0 1))
  (origs (n1 (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 n2-0 text) (b a name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk b))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (0 1)
    (enc n1 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 3)
  (parent 2)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0) ((b b) (n1 n1) (a a) (n2 n2))))
  (origs (n1 (0 0))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (non-orig (privk a))
  (uniq-orig n2)
  (goals
    (forall ((a b name) (n2 text) (z0 strd))
      (implies
        (and (p "resp" z0 3) (p "resp" "n2" z0 n2) (p "resp" "a" z0 a)
          (p "resp" "b" z0 b) (non (privk a)) (uniq n2))
        (exists ((z1 strd))
          (and (p "init" z1 2) (p "init" "b" z1 b))))))
  (comment "Responder point of view"
    "Failed authentication goal: agreement on name b")
  (traces
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (label 4)
  (unrealized (0 2))
  (origs (n2 (0 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n2 n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-0))
  (precedes ((0 1) (1 1)) ((1 2) (0 2)))
  (non-orig (privk a))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (0 2)
    (enc n1 n2 (pubk a)))
  (traces
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b))))
    ((send (enc n1 a (pubk b-0))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b-0)))))
  (label 5)
  (parent 4)
  (unrealized)
  (shape)
  (satisfies (no (a a) (b b) (n2 n2) (z0 0)))
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 1))))

(comment "Nothing left to do")

(defprotocol nsl basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 b (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 b (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment
    "Needham-Schroeder-Lowe with no role origination assumptions"))

(defskeleton nsl
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (non-orig (privk a))
  (uniq-orig n2)
  (goals
    (forall ((a b name) (n2 text) (z0 strd))
      (implies
        (and (p "resp" z0 3) (p "resp" "n2" z0 n2) (p "resp" "a" z0 a)
          (p "resp" "b" z0 b) (non (privk a)) (uniq n2))
        (exists ((z1 strd))
          (and (p "init" z1 2) (p "init" "b" z1 b))))))
  (comment "Responder point of view"
    "Authentication goal: agreement on name b")
  (traces
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 b (pubk a)))
      (recv (enc n2 (pubk b)))))
  (label 6)
  (unrealized (0 2))
  (origs (n2 (0 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton nsl
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 1) (1 1)) ((1 2) (0 2)))
  (non-orig (privk a))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (0 2)
    (enc n1 n2 b (pubk a)))
  (traces
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 b (pubk a)))
      (recv (enc n2 (pubk b))))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 b (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 7)
  (parent 6)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 1))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n1 n2 text) (a b name))
  (deflistener n1)
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (goals
    (forall ((a b name) (n1 text) (z0 z1 strd))
      (implies
        (and (p "init" z0 3) (p "init" "n1" z0 n1) (p "init" "a" z0 a)
          (p "init" "b" z0 b) (p "" z1 1) (p "" "x" z1 n1)
          (non (privk a)) (non (privk b)) (uniq n1)) (false))))
  (comment "Initiator point of view"
    "Secrecy goal: nonce n1 not revealed")
  (traces ((recv n1))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 8)
  (unrealized (0 0) (1 1))
  (preskeleton)
  (origs (n1 (1 0)))
  (comment "Not a skeleton"))

(defskeleton ns
  (vars (n1 n2 text) (a b name))
  (deflistener n1)
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((1 0) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (traces ((recv n1))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 9)
  (parent 8)
  (unrealized (0 0) (1 1))
  (origs (n1 (1 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 n2-0 text) (a b name))
  (deflistener n1)
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((1 0) (0 0)) ((1 0) (2 0)) ((2 1) (1 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (1 1)
    (enc n1 a (pubk b)))
  (traces ((recv n1))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 10)
  (parent 9)
  (unrealized (0 0) (1 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 text) (a b name))
  (deflistener n1)
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n1) (b b) (a a))
  (precedes ((1 0) (0 0)) ((1 0) (2 0)) ((2 1) (1 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation nonce-test (contracted (n2-0 n2)) n1 (1 1)
    (enc n1 n2 (pubk a)) (enc n1 a (pubk b)))
  (traces ((recv n1))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))))
  (label 11)
  (parent 10)
  (unrealized (0 0))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton ns
  (vars (n1 n2 text) (a b name))
  (deflistener n1)
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n1) (b b) (a a))
  (precedes ((1 0) (2 0)) ((2 1) (0 0)) ((2 1) (1 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation nonce-test (displaced 3 2 resp 2) n1 (0 0)
    (enc n1 a (pubk b)))
  (traces ((recv n1))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))))
  (label 12)
  (parent 11)
  (unrealized (0 0))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton ns
  (vars (n1 n2 n2-0 text) (a b name))
  (deflistener n1)
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((1 0) (2 0)) ((1 0) (3 0)) ((2 1) (1 1)) ((3 1) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (0 0)
    (enc n1 a (pubk b)))
  (traces ((recv n1))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 13)
  (parent 11)
  (seen 15)
  (unrealized (0 0))
  (comment "1 in cohort - 0 not yet seen"))

(defskeleton ns
  (vars (n2 text) (a b name))
  (deflistener n2)
  (defstrand init 3 (n1 n2) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n2) (b b) (a a))
  (precedes ((1 0) (2 0)) ((1 2) (0 0)) ((2 1) (1 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (operation nonce-test (displaced 3 1 init 3) n2 (0 0)
    (enc n2 n2 (pubk a)) (enc n2 a (pubk b)))
  (traces ((recv n2))
    ((send (enc n2 a (pubk b))) (recv (enc n2 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n2 a (pubk b))) (send (enc n2 n2 (pubk a)))))
  (label 14)
  (parent 12)
  (unrealized (0 0))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 n2-0 text) (a b name))
  (deflistener n1)
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((1 0) (2 0)) ((1 0) (3 0)) ((2 1) (0 0)) ((2 1) (1 1))
    ((3 1) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (0 0)
    (enc n1 n2 (pubk a)) (enc n1 a (pubk b)))
  (traces ((recv n1))
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 15)
  (parent 12)
  (seen 16)
  (unrealized (0 0))
  (comment "1 in cohort - 0 not yet seen"))

(defskeleton ns
  (vars (n2 n2-0 text) (a b name))
  (deflistener n2)
  (defstrand init 3 (n1 n2) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n2) (b b) (a a))
  (defstrand resp 2 (n2 n2-0) (n1 n2) (b b) (a a))
  (precedes ((1 0) (2 0)) ((1 0) (3 0)) ((1 2) (0 0)) ((2 1) (1 1))
    ((3 1) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (operation nonce-test (added-strand resp 2) n2 (0 0) (enc n2 (pubk b))
    (enc n2 n2 (pubk a)) (enc n2 a (pubk b)))
  (traces ((recv n2))
    ((send (enc n2 a (pubk b))) (recv (enc n2 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n2 a (pubk b))) (send (enc n2 n2 (pubk a))))
    ((recv (enc n2 a (pubk b))) (send (enc n2 n2-0 (pubk a)))))
  (label 16)
  (parent 14)
  (unrealized (0 0))
  (dead)
  (comment "empty cohort"))

(comment "Nothing left to do")

(defprotocol unilateral basic
  (defrole init
    (vars (a name) (n text))
    (trace (send (enc n (pubk a))) (recv n)))
  (defrole resp
    (vars (a name) (n text))
    (trace (recv (enc n (pubk a))) (send n)))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Unilateral authentication"))

(defskeleton unilateral
  (vars (n text) (a name))
  (defstrand init 2 (n n) (a a))
  (non-orig (privk a))
  (uniq-orig n)
  (goals
    (forall ((a name) (n text) (z0 strd))
      (implies
        (and (p "init" z0 2) (p "init" "n" z0 n) (p "init" "a" z0 a)
          (non (privk a)) (uniq n))
        (exists ((z1 strd))
          (and (p "resp" z1 2) (p "resp" "a" z1 a))))))
  (comment "Unilateral authentication goal")
  (traces ((send (enc n (pubk a))) (recv n)))
  (label 17)
  (unrealized (0 1))
  (origs (n (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton unilateral
  (vars (n text) (a name))
  (defstrand init 2 (n n) (a a))
  (defstrand resp 2 (n n) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk a))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (0 1) (enc n (pubk a)))
  (traces ((send (enc n (pubk a))) (recv n))
    ((recv (enc n (pubk a))) (send n)))
  (label 18)
  (parent 17)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0) ((a a) (n n))))
  (origs (n (0 0))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n n2 text) (a a-0 name))
  (defstrand init 2 (n1 n) (n2 n2) (a a-0) (b a))
  (non-orig (privk a))
  (uniq-orig n)
  (goals
    (forall ((a name) (n text) (z0 strd))
      (implies
        (and (p "init" z0 2) (p "init" "n1" z0 n) (p "init" "b" z0 a)
          (non (privk a)) (uniq n))
        (exists ((z1 strd))
          (and (p "resp" z1 2) (p "resp" "b" z1 a))))))
  (comment "Initiator authentication goal"
    "Same as unilateral goal under the predicate mapping:"
    (p "init" "n") "->" (p "init" "n1") "and" (p "init" "a") "->"
    (p "init" "b") "and" (p "resp" "a") "->" (p "resp" "b"))
  (traces ((send (enc n a-0 (pubk a))) (recv (enc n n2 (pubk a-0)))))
  (label 19)
  (unrealized (0 1))
  (origs (n (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n n2 n2-0 text) (a a-0 name))
  (defstrand init 2 (n1 n) (n2 n2) (a a-0) (b a))
  (defstrand resp 2 (n2 n2-0) (n1 n) (b a) (a a-0))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk a))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (0 1)
    (enc n a-0 (pubk a)))
  (traces ((send (enc n a-0 (pubk a))) (recv (enc n n2 (pubk a-0))))
    ((recv (enc n a-0 (pubk a))) (send (enc n n2-0 (pubk a-0)))))
  (label 20)
  (parent 19)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0) ((a a) (n n) (a-0 a-0) (n2 n2))))
  (origs (n (0 0))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n n1 text) (a b name))
  (defstrand resp 3 (n2 n) (n1 n1) (b b) (a a))
  (non-orig (privk a))
  (uniq-orig n)
  (goals
    (forall ((a name) (n text) (z0 strd))
      (implies
        (and (p "resp" z0 3) (p "resp" "n2" z0 n) (p "resp" "a" z0 a)
          (non (privk a)) (uniq n))
        (exists ((z1 strd))
          (and (p "init" z1 3) (p "init" "a" z1 a))))))
  (comment "Responder authentication goal"
    "Same as unilateral goal under the predicate mapping:" (p "init" 1)
    "->" (p "resp" 2) "and" (p "init" "n") "->" (p "resp" "n2") "and"
    (p "init" "a") "->" (p "resp" "a") "and" (p "resp" 1) "->"
    (p "init" 2) "and" (p "resp" "a") "->" (p "init" "a"))
  (traces
    ((recv (enc n1 a (pubk b))) (send (enc n1 n (pubk a)))
      (recv (enc n (pubk b)))))
  (label 21)
  (unrealized (0 2))
  (origs (n (0 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n) (a a) (b b-0))
  (precedes ((0 1) (1 1)) ((1 2) (0 2)))
  (non-orig (privk a))
  (uniq-orig n)
  (operation nonce-test (added-strand init 3) n (0 2)
    (enc n1 n (pubk a)))
  (traces
    ((recv (enc n1 a (pubk b))) (send (enc n1 n (pubk a)))
      (recv (enc n (pubk b))))
    ((send (enc n1 a (pubk b-0))) (recv (enc n1 n (pubk a)))
      (send (enc n (pubk b-0)))))
  (label 22)
  (parent 21)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0) ((a a) (n n) (b b) (n1 n1))))
  (origs (n (0 1))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n n2 text) (a b name))
  (defstrand init 2 (n1 n) (n2 n2) (a a) (b b))
  (non-orig (privk a) (privk b))
  (uniq-orig n)
  (goals
    (forall ((a b name) (n text) (z0 strd))
      (implies
        (and (p "init" z0 2) (p "init" "n1" z0 n) (p "init" "a" z0 a)
          (p "init" "b" z0 b) (non (privk a)) (non (privk b)) (uniq n))
        (exists ((z1 strd)) (and (p "resp" z1 2) (p "resp" "b" z1 b)))))
    (forall ((a b name) (n text) (z0 strd))
      (implies
        (and (p "init" z0 2) (p "init" "n1" z0 n) (p "init" "a" z0 a)
          (p "init" "b" z0 b) (non (privk a)) (non (privk b)) (uniq n))
        (exists ((z1 strd))
          (and (p "resp" z1 2) (p "resp" "a" z1 a))))))
  (comment "Two initiator authentication goals")
  (traces ((send (enc n a (pubk b))) (recv (enc n n2 (pubk a)))))
  (label 23)
  (unrealized (0 1))
  (origs (n (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n n2 n2-0 text) (a b name))
  (defstrand init 2 (n1 n) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (0 1)
    (enc n a (pubk b)))
  (traces ((send (enc n a (pubk b))) (recv (enc n n2 (pubk a))))
    ((recv (enc n a (pubk b))) (send (enc n n2-0 (pubk a)))))
  (label 24)
  (parent 23)
  (unrealized (0 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n n2 text) (a b name))
  (defstrand init 2 (n1 n) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n)
  (operation nonce-test (contracted (n2-0 n2)) n (0 1)
    (enc n n2 (pubk a)) (enc n a (pubk b)))
  (traces ((send (enc n a (pubk b))) (recv (enc n n2 (pubk a))))
    ((recv (enc n a (pubk b))) (send (enc n n2 (pubk a)))))
  (label 25)
  (parent 24)
  (unrealized)
  (shape)
  (satisfies yes yes)
  (maps ((0) ((a a) (b b) (n n) (n2 n2))))
  (origs (n (0 0))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n1 n2 text) (b a name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (non-orig (privk b))
  (uniq-orig n1)
  (goals
    (forall ((n1 n2 text) (b a name) (z strd))
      (implies
        (and (p "init" z 3) (p "init" "n1" z n1) (p "init" "n2" z n2)
          (p "init" "a" z a) (p "init" "b" z b) (non (privk b))
          (uniq-at n1 z 0))
        (exists ((n2-0 text) (z-0 strd))
          (and (p "resp" z-0 2) (p "resp" "n2" z-0 n2-0)
            (p "resp" "n1" z-0 n1) (p "resp" "b" z-0 b)
            (p "resp" "a" z-0 a) (prec z 0 z-0 0) (prec z-0 1 z 1))))))
  (comment "Shape analysis sentence")
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 26)
  (unrealized (0 1))
  (origs (n1 (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 n2-0 text) (b a name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk b))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (0 1)
    (enc n1 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 27)
  (parent 26)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0) ((n1 n1) (n2 n2) (b b) (a a))))
  (origs (n1 (0 0))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n2 n1 text) (a b name))
  (deflistener n2)
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (goals
    (forall ((a b name) (n2 text) (z0 z1 strd))
      (implies
        (and (p "resp" z0 3) (p "resp" "n2" z0 n2) (p "resp" "a" z0 a)
          (p "resp" "b" z0 b) (p "" z1 1) (p "" "x" z1 n2)
          (non (privk a)) (non (privk b)) (uniq n2)) (false))))
  (comment "Responder point of view"
    "Failed secrecy goal: nonce n2 not revealed")
  (traces ((recv n2))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (label 28)
  (unrealized (0 0) (1 2))
  (preskeleton)
  (origs (n2 (1 1)))
  (comment "Not a skeleton"))

(defskeleton ns
  (vars (n2 n1 text) (a b name))
  (deflistener n2)
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (precedes ((1 1) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (traces ((recv n2))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (label 29)
  (parent 28)
  (unrealized (0 0) (1 2))
  (origs (n2 (1 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n2 n1 text) (a b b-0 name))
  (deflistener n2)
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-0))
  (precedes ((1 1) (0 0)) ((1 1) (2 1)) ((2 2) (1 2)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (1 2)
    (enc n1 n2 (pubk a)))
  (traces ((recv n2))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b))))
    ((send (enc n1 a (pubk b-0))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b-0)))))
  (label 30)
  (parent 29)
  (unrealized (0 0))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton ns
  (vars (n2 n1 text) (a b b-0 name))
  (deflistener n2)
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-0))
  (precedes ((1 1) (2 1)) ((2 2) (0 0)) ((2 2) (1 2)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (operation nonce-test (displaced 3 2 init 3) n2 (0 0)
    (enc n1 n2 (pubk a)))
  (traces ((recv n2))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b))))
    ((send (enc n1 a (pubk b-0))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b-0)))))
  (label 31)
  (parent 30)
  (unrealized)
  (shape)
  (satisfies (no (a a) (b b) (n2 n2) (z0 1) (z1 0)))
  (maps ((0 1) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (1 1))))

(defskeleton ns
  (vars (n2 n1 text) (a b b-0 b-1 name))
  (deflistener n2)
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-0))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-1))
  (precedes ((1 1) (2 1)) ((1 1) (3 1)) ((2 2) (1 2)) ((3 2) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (0 0)
    (enc n1 n2 (pubk a)))
  (traces ((recv n2))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b))))
    ((send (enc n1 a (pubk b-0))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b-0))))
    ((send (enc n1 a (pubk b-1))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b-1)))))
  (label 32)
  (parent 30)
  (unrealized)
  (shape)
  (satisfies (no (a a) (b b) (n2 n2) (z0 1) (z1 0)))
  (maps ((0 1) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (1 1))))

(comment "Nothing left to do")

(defprotocol ns basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder with no role origination assumptions"))

(defskeleton ns
  (vars (n1 n1-0 n2 n2-0 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand init 3 (n1 n1-0) (n2 n2-0) (a a) (b b))
  (non-orig (privk a) (privk b))
  (uniq-orig n1 n1-0)
  (goals
    (forall ((n1 n1-0 n2 n2-0 text) (a b name) (z z-0 strd))
      (implies
        (and (p "init" z 3) (p "init" z-0 3) (p "init" "n1" z n1)
          (p "init" "n2" z n2) (p "init" "a" z a) (p "init" "b" z b)
          (p "init" "n1" z-0 n1-0) (p "init" "n2" z-0 n2-0)
          (p "init" "a" z-0 a) (p "init" "b" z-0 b) (non (privk a))
          (non (privk b)) (uniq-at n1 z 0) (uniq-at n1-0 z-0 0))
        (= z z-0))))
  (comment "Double initiator point of view")
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((send (enc n1-0 a (pubk b))) (recv (enc n1-0 n2-0 (pubk a)))
      (send (enc n2-0 (pubk b)))))
  (label 33)
  (unrealized (0 1) (1 1))
  (origs (n1 (0 0)) (n1-0 (1 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation collapsed 1 0)
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 34)
  (parent 33)
  (unrealized (0 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n1-0 n2 n2-0 n2-1 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand init 3 (n1 n1-0) (n2 n2-0) (a a) (b b))
  (defstrand resp 2 (n2 n2-1) (n1 n1-0) (b b) (a a))
  (precedes ((1 0) (2 0)) ((2 1) (1 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1 n1-0)
  (operation nonce-test (added-strand resp 2) n1-0 (1 1)
    (enc n1-0 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((send (enc n1-0 a (pubk b))) (recv (enc n1-0 n2-0 (pubk a)))
      (send (enc n2-0 (pubk b))))
    ((recv (enc n1-0 a (pubk b))) (send (enc n1-0 n2-1 (pubk a)))))
  (label 35)
  (parent 33)
  (unrealized (0 1) (1 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 n2-0 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (0 1)
    (enc n1 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 36)
  (parent 34)
  (unrealized (0 1))
  (origs (n1 (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n1-0 n2 n2-0 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand init 3 (n1 n1-0) (n2 n2-0) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1-0) (b b) (a a))
  (precedes ((1 0) (2 0)) ((2 1) (1 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1 n1-0)
  (operation nonce-test (contracted (n2-1 n2-0)) n1-0 (1 1)
    (enc n1-0 n2-0 (pubk a)) (enc n1-0 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((send (enc n1-0 a (pubk b))) (recv (enc n1-0 n2-0 (pubk a)))
      (send (enc n2-0 (pubk b))))
    ((recv (enc n1-0 a (pubk b))) (send (enc n1-0 n2-0 (pubk a)))))
  (label 37)
  (parent 35)
  (unrealized (0 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n2 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n1) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1)
  (operation nonce-test (contracted (n2-0 n2)) n1 (0 1)
    (enc n1 n2 (pubk a)) (enc n1 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2 (pubk a)))))
  (label 38)
  (parent 36)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps ((0 0) ((a a) (b b) (n1 n1) (n1-0 n1) (n2 n2) (n2-0 n2))))
  (origs (n1 (0 0))))

(defskeleton ns
  (vars (n1 n1-0 n2 n2-0 n2-1 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand init 3 (n1 n1-0) (n2 n2-0) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1-0) (b b) (a a))
  (defstrand resp 2 (n2 n2-1) (n1 n1) (b b) (a a))
  (precedes ((0 0) (3 0)) ((1 0) (2 0)) ((2 1) (1 1)) ((3 1) (0 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1 n1-0)
  (operation nonce-test (added-strand resp 2) n1 (0 1)
    (enc n1 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((send (enc n1-0 a (pubk b))) (recv (enc n1-0 n2-0 (pubk a)))
      (send (enc n2-0 (pubk b))))
    ((recv (enc n1-0 a (pubk b))) (send (enc n1-0 n2-0 (pubk a))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-1 (pubk a)))))
  (label 39)
  (parent 37)
  (unrealized (0 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton ns
  (vars (n1 n1-0 n2 n2-0 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2-0) (a a) (b b))
  (defstrand init 3 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n1-0) (b b) (a a))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((0 0) (3 0)) ((1 0) (2 0)) ((2 1) (1 1)) ((3 1) (0 1)))
  (non-orig (privk a) (privk b))
  (uniq-orig n1 n1-0)
  (operation nonce-test (contracted (n2-1 n2-0)) n1 (0 1)
    (enc n1 n2-0 (pubk a)) (enc n1 a (pubk b)))
  (traces
    ((send (enc n1 a (pubk b))) (recv (enc n1 n2-0 (pubk a)))
      (send (enc n2-0 (pubk b))))
    ((send (enc n1-0 a (pubk b))) (recv (enc n1-0 n2 (pubk a)))
      (send (enc n2 (pubk b))))
    ((recv (enc n1-0 a (pubk b))) (send (enc n1-0 n2 (pubk a))))
    ((recv (enc n1 a (pubk b))) (send (enc n1 n2-0 (pubk a)))))
  (label 40)
  (parent 39)
  (unrealized)
  (shape)
  (satisfies
    (no (n1 n1) (n1-0 n1-0) (n2 n2-0) (n2-0 n2) (a a) (b b) (z 0)
      (z-0 1)))
  (maps ((0 1) ((a a) (b b) (n1 n1) (n1-0 n1-0) (n2 n2-0) (n2-0 n2))))
  (origs (n1 (0 0)) (n1-0 (1 0))))

(comment "Nothing left to do")

(defprotocol nsl-typeless basic
  (defrole init
    (vars (a b name) (n1 text) (n2 mesg))
    (trace (send (enc a n1 (pubk b))) (recv (enc n1 n2 b (pubk a)))
      (send (enc n2 (pubk b)))))
  (defrole resp
    (vars (b a name) (n2 text) (n1 mesg))
    (trace (recv (enc a n1 (pubk b))) (send (enc n1 n2 b (pubk a)))
      (recv (enc n2 (pubk b)))))
  (defgenrule neqRl_indx
    (forall ((x indx)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_strd
    (forall ((x strd)) (implies (fact neq x x) (false))))
  (defgenrule neqRl_mesg
    (forall ((x mesg)) (implies (fact neq x x) (false))))
  (defgenrule no-interruption
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (leads-to z0 i0 z2 i2) (trans z1 i1)
          (same-locn z0 i0 z1 i1) (prec z0 i0 z1 i1) (prec z1 i1 z2 i2))
        (false))))
  (defgenrule cakeRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (leads-to z0 i0 z1 i1)
          (leads-to z0 i0 z2 i2) (prec z1 i1 z2 i2)) (false))))
  (defgenrule scissorsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (leads-to z0 i0 z2 i2))
        (and (= z1 z2) (= i1 i2)))))
  (defgenrule invShearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (same-locn z0 i0 z1 i1)
          (leads-to z1 i1 z2 i2) (prec z0 i0 z2 i2))
        (or (and (= z0 z1) (= i0 i1)) (prec z0 i0 z1 i1)))))
  (defgenrule shearsRule
    (forall ((z0 z1 z2 strd) (i0 i1 i2 indx))
      (implies
        (and (trans z0 i0) (trans z1 i1) (trans z2 i2)
          (leads-to z0 i0 z1 i1) (same-locn z0 i0 z2 i2)
          (prec z0 i0 z2 i2))
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2)))))
  (comment "Needham-Schroeder-Lowe with untyped nonces"))

(defskeleton nsl-typeless
  (vars (n1 mesg) (n2 text) (a b name))
  (deflistener n2)
  (defstrand resp 2 (n1 n1) (n2 n2) (b b) (a a))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (goals
    (forall ((n2 text) (a b name) (z z-0 strd))
      (implies
        (and (p "resp" z 2) (p "" z-0 1) (p "resp" "n2" z n2)
          (p "resp" "b" z b) (p "resp" "a" z a) (p "" "x" z-0 n2)
          (non (privk a)) (non (privk b)) (uniq n2)) (false))))
  (comment "Shows typeflaw in typeless NSL")
  (traces ((recv n2))
    ((recv (enc a n1 (pubk b))) (send (enc n1 n2 b (pubk a)))))
  (label 41)
  (unrealized (0 0))
  (preskeleton)
  (origs (n2 (1 1)))
  (comment "Not a skeleton"))

(defskeleton nsl-typeless
  (vars (n1 mesg) (n2 text) (a b name))
  (deflistener n2)
  (defstrand resp 2 (n1 n1) (n2 n2) (b b) (a a))
  (precedes ((1 1) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (traces ((recv n2))
    ((recv (enc a n1 (pubk b))) (send (enc n1 n2 b (pubk a)))))
  (label 42)
  (parent 41)
  (unrealized (0 0))
  (origs (n2 (1 1)))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton nsl-typeless
  (vars (n2 n1 text) (a b name))
  (deflistener n2)
  (defstrand resp 2 (n1 n1) (n2 n2) (b b) (a a))
  (defstrand init 3 (n2 n2) (n1 n1) (a a) (b b))
  (precedes ((1 1) (2 1)) ((2 2) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (0 0)
    (enc n1 n2 b (pubk a)))
  (traces ((recv n2))
    ((recv (enc a n1 (pubk b))) (send (enc n1 n2 b (pubk a))))
    ((send (enc a n1 (pubk b))) (recv (enc n1 n2 b (pubk a)))
      (send (enc n2 (pubk b)))))
  (label 43)
  (parent 42)
  (unrealized (0 0))
  (dead)
  (comment "empty cohort"))

(defskeleton nsl-typeless
  (vars (n2 n2-0 text) (a b a-0 name))
  (deflistener n2)
  (defstrand resp 2 (n1 a-0) (n2 n2) (b b) (a a))
  (defstrand resp 2 (n1 (cat n2 b)) (n2 n2-0) (b a) (a a-0))
  (precedes ((1 1) (2 0)) ((2 1) (0 0)))
  (non-orig (privk a) (privk b))
  (uniq-orig n2)
  (operation nonce-test (added-strand resp 2) n2 (0 0)
    (enc a-0 n2 b (pubk a)))
  (traces ((recv n2))
    ((recv (enc a a-0 (pubk b))) (send (enc a-0 n2 b (pubk a))))
    ((recv (enc a-0 n2 b (pubk a)))
      (send (enc (cat n2 b) n2-0 a (pubk a-0)))))
  (label 44)
  (parent 42)
  (unrealized)
  (shape)
  (satisfies (no (n2 n2) (a a) (b b) (z 1) (z-0 0)))
  (maps ((0 1) ((n2 n2) (a a) (b b) (n1 a-0))))
  (origs (n2 (1 1))))

(comment "Nothing left to do")
