(comment "CPSA 4.3.0")
(comment "All input read from tst/uncarried_keys.scm")

(defprotocol uncarried-keys basic
  (defrole init
    (vars (a text) (A B name) (K akey))
    (trace (send (enc "start" a A B (pubk B)))
      (recv (enc a A B (pubk A))) (send (enc a K (pubk B)))
      (recv (enc a A B K)))
    (non-orig (invk K) (privk B))
    (uniq-orig a K))
  (defrole resp
    (vars (a text) (A B name) (K akey))
    (trace (recv (enc "start" a A B (pubk B)))
      (send (enc a A B (pubk A))) (recv (enc a K (pubk B)))
      (send (enc a A B K))))
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

(defskeleton uncarried-keys
  (vars (a text) (K akey) (A B name))
  (defstrand init 4 (a a) (K K) (A A) (B B))
  (non-orig (invk K) (privk B))
  (uniq-orig a K)
  (traces
    ((send (enc "start" a A B (pubk B))) (recv (enc a A B (pubk A)))
      (send (enc a K (pubk B))) (recv (enc a A B K))))
  (label 0)
  (unrealized (0 1) (0 3))
  (origs (K (0 2)) (a (0 0)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton uncarried-keys
  (vars (a text) (K akey) (A B name))
  (defstrand init 4 (a a) (K K) (A A) (B B))
  (defstrand resp 2 (a a) (A A) (B B))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (invk K) (privk B))
  (uniq-orig a K)
  (operation nonce-test (added-strand resp 2) a (0 1)
    (enc "start" a A B (pubk B)))
  (traces
    ((send (enc "start" a A B (pubk B))) (recv (enc a A B (pubk A)))
      (send (enc a K (pubk B))) (recv (enc a A B K)))
    ((recv (enc "start" a A B (pubk B))) (send (enc a A B (pubk A)))))
  (label 1)
  (parent 0)
  (unrealized (0 3))
  (comment "4 in cohort - 4 not yet seen"))

(defskeleton uncarried-keys
  (vars (a text) (K akey) (A B name))
  (defstrand init 4 (a a) (K K) (A A) (B B))
  (defstrand resp 2 (a a) (A A) (B B))
  (defstrand resp 4 (a a) (K K) (A A) (B B))
  (precedes ((0 0) (1 0)) ((0 0) (2 0)) ((0 2) (2 2)) ((1 1) (0 1))
    ((2 3) (0 3)))
  (non-orig (invk K) (privk B))
  (uniq-orig a K)
  (operation encryption-test (added-strand resp 4) (enc a A B K) (0 3))
  (traces
    ((send (enc "start" a A B (pubk B))) (recv (enc a A B (pubk A)))
      (send (enc a K (pubk B))) (recv (enc a A B K)))
    ((recv (enc "start" a A B (pubk B))) (send (enc a A B (pubk A))))
    ((recv (enc "start" a A B (pubk B))) (send (enc a A B (pubk A)))
      (recv (enc a K (pubk B))) (send (enc a A B K))))
  (label 2)
  (parent 1)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (A A) (B B) (K K))))
  (origs (K (0 2)) (a (0 0))))

(defskeleton uncarried-keys
  (vars (a text) (K akey) (A B name))
  (defstrand init 4 (a a) (K K) (A A) (B B))
  (defstrand resp 4 (a a) (K K) (A A) (B B))
  (precedes ((0 0) (1 0)) ((0 2) (1 2)) ((1 1) (0 1)) ((1 3) (0 3)))
  (non-orig (invk K) (privk B))
  (uniq-orig a K)
  (operation encryption-test (displaced 1 2 resp 4) (enc a A B K) (0 3))
  (traces
    ((send (enc "start" a A B (pubk B))) (recv (enc a A B (pubk A)))
      (send (enc a K (pubk B))) (recv (enc a A B K)))
    ((recv (enc "start" a A B (pubk B))) (send (enc a A B (pubk A)))
      (recv (enc a K (pubk B))) (send (enc a A B K))))
  (label 3)
  (parent 1)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (A A) (B B) (K K))))
  (origs (K (0 2)) (a (0 0))))

(defskeleton uncarried-keys
  (vars (a text) (A B name))
  (defstrand init 4 (a a) (K (pubk A)) (A A) (B B))
  (defstrand resp 2 (a a) (A A) (B B))
  (precedes ((0 0) (1 0)) ((1 1) (0 1)))
  (non-orig (privk A) (privk B))
  (uniq-orig a (pubk A))
  (operation encryption-test (displaced 2 1 resp 2) (enc a A B (pubk A))
    (0 3))
  (traces
    ((send (enc "start" a A B (pubk B))) (recv (enc a A B (pubk A)))
      (send (enc a (pubk A) (pubk B))) (recv (enc a A B (pubk A))))
    ((recv (enc "start" a A B (pubk B))) (send (enc a A B (pubk A)))))
  (label 4)
  (parent 1)
  (unrealized)
  (shape)
  (maps ((0) ((a a) (A A) (B B) (K (pubk A)))))
  (origs ((pubk A) (0 2)) (a (0 0))))

(defskeleton uncarried-keys
  (vars (a text) (K akey) (A B name))
  (defstrand init 4 (a a) (K K) (A A) (B B))
  (defstrand resp 2 (a a) (A A) (B B))
  (deflistener K)
  (precedes ((0 0) (1 0)) ((0 2) (2 0)) ((1 1) (0 1)) ((2 1) (0 3)))
  (non-orig (invk K) (privk B))
  (uniq-orig a K)
  (operation encryption-test (added-listener K) (enc a A B K) (0 3))
  (traces
    ((send (enc "start" a A B (pubk B))) (recv (enc a A B (pubk A)))
      (send (enc a K (pubk B))) (recv (enc a A B K)))
    ((recv (enc "start" a A B (pubk B))) (send (enc a A B (pubk A))))
    ((recv K) (send K)))
  (label 5)
  (parent 1)
  (unrealized (2 0))
  (dead)
  (comment "empty cohort"))

(comment "Nothing left to do")
