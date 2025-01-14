(herald auth-hash)

(comment "CPSA 4.3.0")
(comment "All input read from tst/auth-hash.scm")

(defprotocol auth-hash basic
  (defrole init
    (vars (n text) (ch chan))
    (trace (send ch (hash n)) (send ch n))
    (uniq-orig n)
    (inputs ch))
  (defrole resp
    (vars (n text) (ch chan))
    (trace (recv ch (hash n)) (recv ch n))
    (inputs ch)
    (outputs n))
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
        (or (and (= z1 z2) (= i1 i2)) (prec z1 i1 z2 i2))))))

(defskeleton auth-hash
  (vars (n text) (ch chan))
  (defstrand resp 2 (n n) (ch ch))
  (auth ch)
  (traces ((recv ch (hash n)) (recv ch n)))
  (label 0)
  (unrealized (0 0) (0 1))
  (origs)
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton auth-hash
  (vars (n text) (ch chan))
  (defstrand resp 2 (n n) (ch ch))
  (defstrand init 1 (n n) (ch ch))
  (precedes ((1 0) (0 0)))
  (auth ch)
  (operation channel-test (added-strand init 1) (ch-msg ch (hash n))
    (0 0))
  (traces ((recv ch (hash n)) (recv ch n)) ((send ch (hash n))))
  (label 1)
  (parent 0)
  (unrealized (0 1))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton auth-hash
  (vars (n text) (ch chan))
  (defstrand resp 2 (n n) (ch ch))
  (defstrand init 2 (n n) (ch ch))
  (precedes ((1 0) (0 0)) ((1 1) (0 1)))
  (uniq-orig n)
  (auth ch)
  (operation channel-test (displaced 1 2 init 2) (ch-msg ch n) (0 1))
  (traces ((recv ch (hash n)) (recv ch n))
    ((send ch (hash n)) (send ch n)))
  (label 2)
  (parent 1)
  (unrealized)
  (shape)
  (maps ((0) ((ch ch) (n n))))
  (origs (n (1 1))))

(defskeleton auth-hash
  (vars (n text) (ch chan))
  (defstrand resp 2 (n n) (ch ch))
  (defstrand init 1 (n n) (ch ch))
  (defstrand init 2 (n n) (ch ch))
  (precedes ((1 0) (0 0)) ((2 1) (0 1)))
  (uniq-orig n)
  (auth ch)
  (operation channel-test (added-strand init 2) (ch-msg ch n) (0 1))
  (traces ((recv ch (hash n)) (recv ch n)) ((send ch (hash n)))
    ((send ch (hash n)) (send ch n)))
  (label 3)
  (parent 1)
  (unrealized)
  (shape)
  (maps ((0) ((ch ch) (n n))))
  (origs (n (2 1))))

(comment "Nothing left to do")
