(herald "Signed Encrypted Message Example"
  (comment "Shows examples of key usage of asymmetric keys"))

(comment "CPSA 4.3.0")
(comment "All input read from tst/sigenc.scm")

(defprotocol mult-keys-sig-enc basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
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

(defskeleton mult-keys-sig-enc
  (vars (n1 n2 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (non-orig (privk "enc" a) (privk "enc" b) (privk "sig" a))
  (uniq-orig n1)
  (traces
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 0)
  (unrealized (0 1))
  (origs (n1 (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n1 n2 n2-0 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2-0) (n1 n1) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk "enc" a) (privk "enc" b) (privk "sig" a))
  (uniq-orig n1)
  (operation nonce-test (added-strand resp 2) n1 (0 1)
    (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
  (traces
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2-0 (privk "sig" b)) (pubk "enc" a)))))
  (label 1)
  (parent 0)
  (unrealized (0 1))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n1 n2 text) (a b name))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (defstrand resp 2 (n2 n2) (n1 n1) (b b) (a a))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk "enc" a) (privk "enc" b) (privk "sig" a))
  (uniq-orig n1)
  (operation nonce-test (contracted (n2-0 n2)) n1 (0 1)
    (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a))
    (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
  (traces
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))))
  (label 2)
  (parent 1)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n1 n1) (n2 n2))))
  (origs (n1 (0 0))))

(comment "Nothing left to do")

(defprotocol mult-keys-sig-enc basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
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

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (non-orig (privk "sig" a))
  (uniq-orig n2)
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 3)
  (unrealized (0 0) (0 2))
  (origs (n2 (0 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 1 (n1 n1) (a a) (b b-0))
  (precedes ((1 0) (0 0)))
  (non-orig (privk "sig" a))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 1)
    (enc n1 a (privk "sig" a)) (0 0))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0)))))
  (label 4)
  (parent 3)
  (unrealized (0 2))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-0))
  (precedes ((0 1) (1 1)) ((1 0) (0 0)) ((1 2) (0 2)))
  (non-orig (privk "sig" a))
  (uniq-orig n2)
  (operation encryption-test (displaced 1 2 init 3)
    (enc n2 (privk "sig" a)) (0 2))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0)))
      (recv (enc (enc n1 n2 (privk "sig" b-0)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b-0)))))
  (label 5)
  (parent 4)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 1))))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 n1-0 text) (a b b-0 b-1 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 1 (n1 n1) (a a) (b b-0))
  (defstrand init 3 (n1 n1-0) (n2 n2) (a a) (b b-1))
  (precedes ((0 1) (2 1)) ((1 0) (0 0)) ((2 2) (0 2)))
  (non-orig (privk "sig" a))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3)
    (enc n2 (privk "sig" a)) (0 2))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0))))
    ((send (enc (enc n1-0 a (privk "sig" a)) (pubk "enc" b-1)))
      (recv (enc (enc n1-0 n2 (privk "sig" b-1)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b-1)))))
  (label 6)
  (parent 4)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 1))))

(comment "Nothing left to do")

(defprotocol mult-keys-sig-enc basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
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

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (non-orig (privk "enc" a))
  (uniq-orig n2)
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 7)
  (unrealized (0 2))
  (origs (n2 (0 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 1) (1 1)) ((1 2) (0 2)))
  (non-orig (privk "enc" a))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (0 2)
    (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 8)
  (parent 7)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 1))))

(comment "Nothing left to do")

(defprotocol mult-keys-sig-enc basic
  (defrole init
    (vars (a b name) (n1 n2 text))
    (trace (send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (defrole resp
    (vars (b a name) (n2 n1 text))
    (trace (recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
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

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 9)
  (unrealized (0 0) (0 2))
  (origs (n2 (0 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 1 (n1 n1) (a a) (b b-0))
  (precedes ((1 0) (0 0)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 1)
    (enc n1 a (privk "sig" a)) (0 0))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0)))))
  (label 10)
  (parent 9)
  (unrealized (0 2))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-0))
  (precedes ((0 1) (1 1)) ((1 0) (0 0)) ((1 2) (0 2)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation encryption-test (displaced 1 2 init 3)
    (enc n2 (privk "sig" a)) (0 2))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0)))
      (recv (enc (enc n1 n2 (privk "sig" b-0)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b-0)))))
  (label 11)
  (parent 10)
  (unrealized (1 1))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 n1-0 text) (a b b-0 b-1 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 1 (n1 n1) (a a) (b b-0))
  (defstrand init 3 (n1 n1-0) (n2 n2) (a a) (b b-1))
  (precedes ((0 1) (2 1)) ((1 0) (0 0)) ((2 2) (0 2)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation encryption-test (added-strand init 3)
    (enc n2 (privk "sig" a)) (0 2))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0))))
    ((send (enc (enc n1-0 a (privk "sig" a)) (pubk "enc" b-1)))
      (recv (enc (enc n1-0 n2 (privk "sig" b-1)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b-1)))))
  (label 12)
  (parent 10)
  (unrealized (2 1))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 1) (1 1)) ((1 0) (0 0)) ((1 2) (0 2)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation nonce-test (contracted (b-0 b)) n2 (1 1)
    (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 13)
  (parent 11)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 1))))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b-0))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 1) (2 1)) ((1 0) (0 0)) ((1 2) (0 2)) ((2 2) (1 1)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (1 1)
    (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0)))
      (recv (enc (enc n1 n2 (privk "sig" b-0)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b-0))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 14)
  (parent 11)
  (seen 15)
  (unrealized)
  (comment "1 in cohort - 0 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 1 (n1 n1) (a a) (b b-0))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 1) (2 1)) ((1 0) (0 0)) ((2 2) (0 2)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation nonce-test (contracted (b-1 b) (n1-0 n1)) n2 (2 1)
    (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 15)
  (parent 12)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (b b) (n2 n2) (n1 n1))))
  (origs (n2 (0 1))))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 n1-0 text) (a b b-0 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 3 (n1 n1-0) (n2 n2) (a a) (b b-0))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 1) (2 1)) ((1 2) (0 2)) ((2 0) (0 0)) ((2 2) (1 1)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation nonce-test (displaced 1 3 init 3) n2 (2 1)
    (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1-0 a (privk "sig" a)) (pubk "enc" b-0)))
      (recv (enc (enc n1-0 n2 (privk "sig" b-0)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b-0))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 16)
  (parent 12)
  (seen 13)
  (unrealized)
  (comment "1 in cohort - 0 not yet seen"))

(defskeleton mult-keys-sig-enc
  (vars (n2 n1 n1-0 text) (a b b-0 b-1 name))
  (defstrand resp 3 (n2 n2) (n1 n1) (b b) (a a))
  (defstrand init 1 (n1 n1) (a a) (b b-0))
  (defstrand init 3 (n1 n1-0) (n2 n2) (a a) (b b-1))
  (defstrand init 3 (n1 n1) (n2 n2) (a a) (b b))
  (precedes ((0 1) (3 1)) ((1 0) (0 0)) ((2 2) (0 2)) ((3 2) (2 1)))
  (non-orig (privk "enc" a) (privk "sig" a))
  (uniq-orig n2)
  (operation nonce-test (added-strand init 3) n2 (2 1)
    (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
  (traces
    ((recv (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (send (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (recv (enc (enc n2 (privk "sig" a)) (pubk "enc" b))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b-0))))
    ((send (enc (enc n1-0 a (privk "sig" a)) (pubk "enc" b-1)))
      (recv (enc (enc n1-0 n2 (privk "sig" b-1)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b-1))))
    ((send (enc (enc n1 a (privk "sig" a)) (pubk "enc" b)))
      (recv (enc (enc n1 n2 (privk "sig" b)) (pubk "enc" a)))
      (send (enc (enc n2 (privk "sig" a)) (pubk "enc" b)))))
  (label 17)
  (parent 12)
  (seen 15)
  (unrealized)
  (comment "1 in cohort - 0 not yet seen"))

(comment "Nothing left to do")
