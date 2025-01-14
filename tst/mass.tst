(comment "CPSA 4.3.0")
(comment "All input read from tst/mass.lsp")

(defprotocol mass basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b)))))
  (defrole resp
    (vars (a b name) (n1 n2 text))
    (trace (recv a) (send n1) (recv (enc n1 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b)))))
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

(defskeleton mass
  (vars (n2 n1 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b)))))
  (label 0)
  (unrealized (0 4))
  (origs (n2 (0 3)))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton mass
  (vars (n2 n1 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand init 3 (n1 n2) (a a) (b b))
  (precedes ((0 3) (1 1)) ((1 2) (0 4)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3) (enc n2 (ltk a b))
    (0 4))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((send a) (recv n2) (send (enc n2 (ltk a b)))))
  (label 1)
  (parent 0)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand resp 5) (enc n2 (ltk a b))
    (0 4))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b)))))
  (label 2)
  (parent 0)
  (unrealized (1 2))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton mass
  (vars (n2 n1 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 2) (1 2)) ((0 3) (1 3)) ((1 4) (0 4)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (displaced 2 0 init 3) (enc n1-0 (ltk a b))
    (1 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1) (recv (enc n1 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b)))))
  (label 3)
  (parent 2)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand init 3 (n1 n1-0) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 2) (1 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3) (enc n1-0 (ltk a b))
    (1 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((send a) (recv n1-0) (send (enc n1-0 (ltk a b)))))
  (label 4)
  (parent 2)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand resp 5) (enc n1-0 (ltk a b))
    (1 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b)))))
  (label 5)
  (parent 2)
  (unrealized (2 2))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton mass
  (vars (n2 n1 n1-0 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1) (n2 n1-0) (a a) (b b))
  (precedes ((0 2) (2 2)) ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (displaced 3 0 init 3) (enc n1-1 (ltk a b))
    (2 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1) (recv (enc n1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b)))))
  (label 6)
  (parent 5)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand init 3 (n1 n1-1) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 2) (2 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3) (enc n1-1 (ltk a b))
    (2 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((send a) (recv n1-1) (send (enc n1-1 (ltk a b)))))
  (label 7)
  (parent 5)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand resp 5) (enc n1-1 (ltk a b))
    (2 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b)))))
  (label 8)
  (parent 5)
  (unrealized (3 2))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1) (n2 n1-1) (a a) (b b))
  (precedes ((0 2) (3 2)) ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2))
    ((3 4) (2 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (displaced 4 0 init 3) (enc n1-2 (ltk a b))
    (3 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1) (recv (enc n1 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b)))))
  (label 9)
  (parent 8)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand init 3 (n1 n1-2) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 2) (3 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3) (enc n1-2 (ltk a b))
    (3 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((send a) (recv n1-2) (send (enc n1-2 (ltk a b)))))
  (label 10)
  (parent 8)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 4) (3 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand resp 5) (enc n1-2 (ltk a b))
    (3 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b)))))
  (label 11)
  (parent 8)
  (unrealized (4 2))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1) (n2 n1-2) (a a) (b b))
  (precedes ((0 2) (4 2)) ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2))
    ((3 4) (2 2)) ((4 4) (3 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (displaced 5 0 init 3) (enc n1-3 (ltk a b))
    (4 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1) (recv (enc n1 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b)))))
  (label 12)
  (parent 11)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand init 3 (n1 n1-3) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 4) (3 2)) ((5 2) (4 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3) (enc n1-3 (ltk a b))
    (4 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((send a) (recv n1-3) (send (enc n1-3 (ltk a b)))))
  (label 13)
  (parent 11)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 n1-4 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand resp 5 (n1 n1-4) (n2 n1-3) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 4) (3 2)) ((5 4) (4 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand resp 5) (enc n1-3 (ltk a b))
    (4 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((recv a) (send n1-4) (recv (enc n1-4 (ltk a b))) (recv n1-3)
      (send (enc n1-3 (ltk a b)))))
  (label 14)
  (parent 11)
  (unrealized (5 2))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand resp 5 (n1 n1) (n2 n1-3) (a a) (b b))
  (precedes ((0 2) (5 2)) ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2))
    ((3 4) (2 2)) ((4 4) (3 2)) ((5 4) (4 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (displaced 6 0 init 3) (enc n1-4 (ltk a b))
    (5 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((recv a) (send n1) (recv (enc n1 (ltk a b))) (recv n1-3)
      (send (enc n1-3 (ltk a b)))))
  (label 15)
  (parent 14)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 n1-4 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand resp 5 (n1 n1-4) (n2 n1-3) (a a) (b b))
  (defstrand init 3 (n1 n1-4) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 4) (3 2)) ((5 4) (4 2)) ((6 2) (5 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3) (enc n1-4 (ltk a b))
    (5 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((recv a) (send n1-4) (recv (enc n1-4 (ltk a b))) (recv n1-3)
      (send (enc n1-3 (ltk a b))))
    ((send a) (recv n1-4) (send (enc n1-4 (ltk a b)))))
  (label 16)
  (parent 14)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 n1-4 n1-5 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand resp 5 (n1 n1-4) (n2 n1-3) (a a) (b b))
  (defstrand resp 5 (n1 n1-5) (n2 n1-4) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 4) (3 2)) ((5 4) (4 2)) ((6 4) (5 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand resp 5) (enc n1-4 (ltk a b))
    (5 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((recv a) (send n1-4) (recv (enc n1-4 (ltk a b))) (recv n1-3)
      (send (enc n1-3 (ltk a b))))
    ((recv a) (send n1-5) (recv (enc n1-5 (ltk a b))) (recv n1-4)
      (send (enc n1-4 (ltk a b)))))
  (label 17)
  (parent 14)
  (unrealized (6 2))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 n1-4 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand resp 5 (n1 n1-4) (n2 n1-3) (a a) (b b))
  (defstrand resp 5 (n1 n1) (n2 n1-4) (a a) (b b))
  (precedes ((0 2) (6 2)) ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2))
    ((3 4) (2 2)) ((4 4) (3 2)) ((5 4) (4 2)) ((6 4) (5 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (displaced 7 0 init 3) (enc n1-5 (ltk a b))
    (6 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((recv a) (send n1-4) (recv (enc n1-4 (ltk a b))) (recv n1-3)
      (send (enc n1-3 (ltk a b))))
    ((recv a) (send n1) (recv (enc n1 (ltk a b))) (recv n1-4)
      (send (enc n1-4 (ltk a b)))))
  (label 18)
  (parent 17)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 n1-4 n1-5 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand resp 5 (n1 n1-4) (n2 n1-3) (a a) (b b))
  (defstrand resp 5 (n1 n1-5) (n2 n1-4) (a a) (b b))
  (defstrand init 3 (n1 n1-5) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 4) (3 2)) ((5 4) (4 2)) ((6 4) (5 2)) ((7 2) (6 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3) (enc n1-5 (ltk a b))
    (6 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((recv a) (send n1-4) (recv (enc n1-4 (ltk a b))) (recv n1-3)
      (send (enc n1-3 (ltk a b))))
    ((recv a) (send n1-5) (recv (enc n1-5 (ltk a b))) (recv n1-4)
      (send (enc n1-4 (ltk a b))))
    ((send a) (recv n1-5) (send (enc n1-5 (ltk a b)))))
  (label 19)
  (parent 17)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 3))))

(comment "Strand bound exceeded--aborting run")

(defskeleton mass
  (vars (n2 n1 n1-0 n1-1 n1-2 n1-3 n1-4 n1-5 n1-6 text) (a b name))
  (defstrand init 5 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-0) (n2 n2) (a a) (b b))
  (defstrand resp 5 (n1 n1-1) (n2 n1-0) (a a) (b b))
  (defstrand resp 5 (n1 n1-2) (n2 n1-1) (a a) (b b))
  (defstrand resp 5 (n1 n1-3) (n2 n1-2) (a a) (b b))
  (defstrand resp 5 (n1 n1-4) (n2 n1-3) (a a) (b b))
  (defstrand resp 5 (n1 n1-5) (n2 n1-4) (a a) (b b))
  (defstrand resp 5 (n1 n1-6) (n2 n1-5) (a a) (b b))
  (precedes ((0 3) (1 3)) ((1 4) (0 4)) ((2 4) (1 2)) ((3 4) (2 2))
    ((4 4) (3 2)) ((5 4) (4 2)) ((6 4) (5 2)) ((7 4) (6 2)))
  (non-orig (ltk a b))
  (uniq-orig n2)
  (operation encryption-test (added-strand resp 5) (enc n1-5 (ltk a b))
    (6 2))
  (traces
    ((send a) (recv n1) (send (enc n1 (ltk a b))) (send n2)
      (recv (enc n2 (ltk a b))))
    ((recv a) (send n1-0) (recv (enc n1-0 (ltk a b))) (recv n2)
      (send (enc n2 (ltk a b))))
    ((recv a) (send n1-1) (recv (enc n1-1 (ltk a b))) (recv n1-0)
      (send (enc n1-0 (ltk a b))))
    ((recv a) (send n1-2) (recv (enc n1-2 (ltk a b))) (recv n1-1)
      (send (enc n1-1 (ltk a b))))
    ((recv a) (send n1-3) (recv (enc n1-3 (ltk a b))) (recv n1-2)
      (send (enc n1-2 (ltk a b))))
    ((recv a) (send n1-4) (recv (enc n1-4 (ltk a b))) (recv n1-3)
      (send (enc n1-3 (ltk a b))))
    ((recv a) (send n1-5) (recv (enc n1-5 (ltk a b))) (recv n1-4)
      (send (enc n1-4 (ltk a b))))
    ((recv a) (send n1-6) (recv (enc n1-6 (ltk a b))) (recv n1-5)
      (send (enc n1-5 (ltk a b)))))
  (label 20)
  (parent 17)
  (unrealized (7 2))
  (aborted)
  (comment "aborted"))
