(comment "CPSA 4.3.0")
(comment "All input read from tst/completeness-test.scm")

(defprotocol completeness-test basic
  (defrole init
    (vars (a b name) (n text) (s skey))
    (trace (send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))))
  (defrole resp
    (vars (a b name) (n text))
    (trace (recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (defrole probe (vars (s skey)) (trace (recv (enc "ok" s))))
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

(defskeleton completeness-test
  (vars (s s-0 skey) (n text) (b a name))
  (defstrand init 3 (s s-0) (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (non-orig s (privk b))
  (uniq-orig n)
  (traces
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s-0))) ((recv (enc "ok" s))))
  (label 0)
  (unrealized (0 1) (1 0))
  (origs (n (0 0)))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n text) (b a name))
  (defstrand init 3 (s s) (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (precedes ((0 2) (1 0)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (displaced 2 0 init 3) (enc "ok" s-0)
    (1 0))
  (traces
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))) ((recv (enc "ok" s))))
  (label 1)
  (parent 0)
  (unrealized (0 1))
  (origs (n (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton completeness-test
  (vars (s s-0 skey) (n n-0 text) (b a a-0 b-0 name))
  (defstrand init 3 (s s-0) (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s) (n n-0) (a a-0) (b b-0))
  (precedes ((2 2) (1 0)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (added-strand init 3) (enc "ok" s) (1 0))
  (traces
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s-0))) ((recv (enc "ok" s)))
    ((send (enc a-0 n-0 (pubk b-0))) (recv (enc n-0 (pubk a-0)))
      (send (enc "ok" s))))
  (label 2)
  (parent 0)
  (unrealized (0 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n text) (b a name))
  (defstrand init 3 (s s) (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (defstrand resp 2 (n n) (a a) (b b))
  (precedes ((0 0) (2 0)) ((0 2) (1 0)) ((2 1) (0 1)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (0 1)
    (enc a n (pubk b)))
  (traces
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))) ((recv (enc "ok" s)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (label 3)
  (parent 1)
  (unrealized)
  (shape)
  (maps ((0 1) ((b b) (n n) (s s) (a a) (s-0 s))))
  (origs (n (0 0))))

(defskeleton completeness-test
  (vars (s s-0 skey) (n n-0 text) (b a a-0 b-0 name))
  (defstrand init 3 (s s-0) (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s) (n n-0) (a a-0) (b b-0))
  (defstrand resp 2 (n n) (a a) (b b))
  (precedes ((0 0) (3 0)) ((2 2) (1 0)) ((3 1) (0 1)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (0 1)
    (enc a n (pubk b)))
  (traces
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s-0))) ((recv (enc "ok" s)))
    ((send (enc a-0 n-0 (pubk b-0))) (recv (enc n-0 (pubk a-0)))
      (send (enc "ok" s)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (label 4)
  (parent 2)
  (unrealized)
  (shape)
  (maps ((0 1) ((b b) (n n) (s s) (a a) (s-0 s-0))))
  (origs (n (0 0))))

(comment "Nothing left to do")

(defprotocol completeness-test basic
  (defrole init
    (vars (a b name) (n text) (s skey))
    (trace (send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))))
  (defrole resp
    (vars (a b name) (n text))
    (trace (recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (defrole probe (vars (s skey)) (trace (recv (enc "ok" s))))
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

(defskeleton completeness-test
  (vars (s s-0 skey) (n text) (b a name))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s-0) (n n) (a a) (b b))
  (non-orig s (privk b))
  (uniq-orig n)
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s-0))))
  (label 5)
  (unrealized (0 0) (1 1))
  (origs (n (1 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton completeness-test
  (vars (s s-0 skey) (n text) (b a name))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s-0) (n n) (a a) (b b))
  (defstrand resp 2 (n n) (a a) (b b))
  (precedes ((1 0) (2 0)) ((2 1) (1 1)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (1 1)
    (enc a n (pubk b)))
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s-0)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (label 6)
  (parent 5)
  (unrealized (0 0))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n text) (b a name))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s) (n n) (a a) (b b))
  (defstrand resp 2 (n n) (a a) (b b))
  (precedes ((1 0) (2 0)) ((1 2) (0 0)) ((2 1) (1 1)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (displaced 3 1 init 3) (enc "ok" s-0)
    (0 0))
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (label 7)
  (parent 6)
  (unrealized)
  (shape)
  (maps ((0 1) ((b b) (n n) (s s) (a a) (s-0 s))))
  (origs (n (1 0))))

(defskeleton completeness-test
  (vars (s s-0 skey) (n n-0 text) (b a a-0 b-0 name))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s-0) (n n) (a a) (b b))
  (defstrand resp 2 (n n) (a a) (b b))
  (defstrand init 3 (s s) (n n-0) (a a-0) (b b-0))
  (precedes ((1 0) (2 0)) ((2 1) (1 1)) ((3 2) (0 0)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (added-strand init 3) (enc "ok" s) (0 0))
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s-0)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a))))
    ((send (enc a-0 n-0 (pubk b-0))) (recv (enc n-0 (pubk a-0)))
      (send (enc "ok" s))))
  (label 8)
  (parent 6)
  (unrealized)
  (shape)
  (maps ((0 1) ((b b) (n n) (s s) (a a) (s-0 s-0))))
  (origs (n (1 0))))

(comment "Nothing left to do")

(defprotocol completeness-test basic
  (defrole init
    (vars (a b name) (n text) (s skey))
    (trace (send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))))
  (defrole resp
    (vars (a b name) (n text))
    (trace (recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (defrole probe (vars (s skey)) (trace (recv (enc "ok" s))))
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

(defskeleton completeness-test
  (vars (s skey) (n text) (b a name))
  (defstrand init 2 (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (non-orig s (privk b))
  (uniq-orig n)
  (traces ((send (enc a n (pubk b))) (recv (enc n (pubk a))))
    ((recv (enc "ok" s))))
  (label 9)
  (unrealized (0 1) (1 0))
  (origs (n (0 0)))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n text) (a b name))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s) (n n) (a a) (b b))
  (precedes ((1 2) (0 0)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (displaced 0 2 init 3) (enc "ok" s) (1 0))
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))))
  (label 10)
  (parent 9)
  (unrealized (1 1))
  (origs (n (1 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n n-0 text) (b a a-0 b-0 name))
  (defstrand init 2 (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s) (n n-0) (a a-0) (b b-0))
  (precedes ((2 2) (1 0)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (added-strand init 3) (enc "ok" s) (1 0))
  (traces ((send (enc a n (pubk b))) (recv (enc n (pubk a))))
    ((recv (enc "ok" s)))
    ((send (enc a-0 n-0 (pubk b-0))) (recv (enc n-0 (pubk a-0)))
      (send (enc "ok" s))))
  (label 11)
  (parent 9)
  (unrealized (0 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n text) (a b name))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s) (n n) (a a) (b b))
  (defstrand resp 2 (n n) (a a) (b b))
  (precedes ((1 0) (2 0)) ((1 2) (0 0)) ((2 1) (1 1)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (1 1)
    (enc a n (pubk b)))
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (label 12)
  (parent 10)
  (unrealized)
  (shape)
  (maps ((1 0) ((b b) (n n) (s s) (a a))))
  (origs (n (1 0))))

(defskeleton completeness-test
  (vars (s skey) (n n-0 text) (b a a-0 b-0 name))
  (defstrand init 2 (n n) (a a) (b b))
  (defstrand probe 1 (s s))
  (defstrand init 3 (s s) (n n-0) (a a-0) (b b-0))
  (defstrand resp 2 (n n) (a a) (b b))
  (precedes ((0 0) (3 0)) ((2 2) (1 0)) ((3 1) (0 1)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (0 1)
    (enc a n (pubk b)))
  (traces ((send (enc a n (pubk b))) (recv (enc n (pubk a))))
    ((recv (enc "ok" s)))
    ((send (enc a-0 n-0 (pubk b-0))) (recv (enc n-0 (pubk a-0)))
      (send (enc "ok" s)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (label 13)
  (parent 11)
  (unrealized)
  (shape)
  (maps ((0 1) ((b b) (n n) (s s) (a a))))
  (origs (n (0 0))))

(comment "Nothing left to do")

(defprotocol completeness-test basic
  (defrole init
    (vars (a b name) (n text) (s skey))
    (trace (send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))))
  (defrole resp
    (vars (a b name) (n text))
    (trace (recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (defrole probe (vars (s skey)) (trace (recv (enc "ok" s))))
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

(defskeleton completeness-test
  (vars (s skey) (n text) (b a name))
  (defstrand probe 1 (s s))
  (defstrand init 2 (n n) (a a) (b b))
  (non-orig s (privk b))
  (uniq-orig n)
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))))
  (label 14)
  (unrealized (0 0) (1 1))
  (origs (n (1 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n text) (b a name))
  (defstrand probe 1 (s s))
  (defstrand init 2 (n n) (a a) (b b))
  (defstrand resp 2 (n n) (a a) (b b))
  (precedes ((1 0) (2 0)) ((2 1) (1 1)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation nonce-test (added-strand resp 2) n (1 1)
    (enc a n (pubk b)))
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a))))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a)))))
  (label 15)
  (parent 14)
  (unrealized (0 0))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton completeness-test
  (vars (s skey) (n text) (a b name))
  (defstrand probe 1 (s s))
  (defstrand resp 2 (n n) (a a) (b b))
  (defstrand init 3 (s s) (n n) (a a) (b b))
  (precedes ((1 1) (2 1)) ((2 0) (1 0)) ((2 2) (0 0)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (displaced 1 3 init 3) (enc "ok" s) (0 0))
  (traces ((recv (enc "ok" s)))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a))))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a)))
      (send (enc "ok" s))))
  (label 16)
  (parent 15)
  (unrealized)
  (shape)
  (maps ((0 2) ((b b) (n n) (s s) (a a))))
  (origs (n (2 0))))

(defskeleton completeness-test
  (vars (s skey) (n n-0 text) (b a a-0 b-0 name))
  (defstrand probe 1 (s s))
  (defstrand init 2 (n n) (a a) (b b))
  (defstrand resp 2 (n n) (a a) (b b))
  (defstrand init 3 (s s) (n n-0) (a a-0) (b b-0))
  (precedes ((1 0) (2 0)) ((2 1) (1 1)) ((3 2) (0 0)))
  (non-orig s (privk b))
  (uniq-orig n)
  (operation encryption-test (added-strand init 3) (enc "ok" s) (0 0))
  (traces ((recv (enc "ok" s)))
    ((send (enc a n (pubk b))) (recv (enc n (pubk a))))
    ((recv (enc a n (pubk b))) (send (enc n (pubk a))))
    ((send (enc a-0 n-0 (pubk b-0))) (recv (enc n-0 (pubk a-0)))
      (send (enc "ok" s))))
  (label 17)
  (parent 15)
  (unrealized)
  (shape)
  (maps ((0 1) ((b b) (n n) (s s) (a a))))
  (origs (n (1 0))))

(comment "Nothing left to do")
