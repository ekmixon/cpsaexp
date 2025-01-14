(comment "CPSA 4.3.0")
(comment "All input read from tst/dh_mim_hack.scm")

(defprotocol dh_mim basic
  (defrole init
    (vars (gx gy akey) (n text) (dhkey skey))
    (trace (send gx) (recv gy) (send (enc n (enc "dh" gx gy dhkey))))
    (non-orig dhkey (invk gx))
    (uniq-orig n gx))
  (defrole resp
    (vars (gx gy akey) (n text) (dhkey skey))
    (trace (recv gx) (send gy) (recv (enc n (enc "dh" gx gy dhkey))))
    (non-orig dhkey (invk gy))
    (uniq-orig gy))
  (defrole CDHcalc1
    (vars (gx gy akey) (dhkey skey))
    (trace (recv (cat gx (invk gy))) (send (enc "dh" gx gy dhkey))))
  (defrole CDHcalc2
    (vars (gx gy akey) (dhkey skey))
    (trace (recv (cat gy (invk gx))) (send (enc "dh" gx gy dhkey))))
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
  (comment "Diffie-hellman key exchange followed by an encryption"))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy gy-0 gx-0 akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy-0))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx-0) (gy gy))
  (precedes ((0 2) (1 2)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (comment "Agreement on the encrypted text only")
  (traces
    ((send gx) (recv gy-0) (send (enc n (enc "dh" gx gy-0 dhkey))))
    ((recv gx-0) (send gy) (recv (enc n (enc "dh" gx-0 gy dhkey)))))
  (label 0)
  (unrealized (1 2))
  (origs (gy (1 1)) (gx (0 0)) (n (0 2)))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx) (gy gy))
  (precedes ((0 0) (1 0)) ((0 2) (1 2)) ((1 1) (0 1)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (operation encryption-test (displaced 2 0 init 3)
    (enc n (enc "dh" gx-0 gy-0 dhkey)) (1 2))
  (traces ((send gx) (recv gy) (send (enc n (enc "dh" gx gy dhkey))))
    ((recv gx) (send gy) (recv (enc n (enc "dh" gx gy dhkey)))))
  (label 1)
  (parent 0)
  (unrealized)
  (shape)
  (maps
    ((0 1) ((n n) (gx gx) (gy gy) (dhkey dhkey) (gy-0 gy) (gx-0 gx))))
  (origs (n (0 2)) (gx (0 0)) (gy (1 1))))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy gy-0 gx-0 akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy-0))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx-0) (gy gy))
  (deflistener (enc "dh" gx-0 gy dhkey))
  (precedes ((0 2) (1 2)) ((1 1) (2 0)) ((2 1) (1 2)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (operation encryption-test (added-listener (enc "dh" gx-0 gy dhkey))
    (enc n (enc "dh" gx-0 gy dhkey)) (1 2))
  (traces
    ((send gx) (recv gy-0) (send (enc n (enc "dh" gx gy-0 dhkey))))
    ((recv gx-0) (send gy) (recv (enc n (enc "dh" gx-0 gy dhkey))))
    ((recv (enc "dh" gx-0 gy dhkey)) (send (enc "dh" gx-0 gy dhkey))))
  (label 2)
  (parent 0)
  (unrealized (1 2) (2 0))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy gy-0 gx-0 akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy-0))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx-0) (gy gy))
  (deflistener (enc "dh" gx-0 gy dhkey))
  (defstrand CDHcalc2 2 (dhkey dhkey) (gx gx-0) (gy gy))
  (precedes ((0 2) (1 2)) ((1 1) (3 0)) ((2 1) (1 2)) ((3 1) (2 0)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (operation encryption-test (added-strand CDHcalc2 2)
    (enc "dh" gx-0 gy dhkey) (2 0))
  (traces
    ((send gx) (recv gy-0) (send (enc n (enc "dh" gx gy-0 dhkey))))
    ((recv gx-0) (send gy) (recv (enc n (enc "dh" gx-0 gy dhkey))))
    ((recv (enc "dh" gx-0 gy dhkey)) (send (enc "dh" gx-0 gy dhkey)))
    ((recv (cat gy (invk gx-0))) (send (enc "dh" gx-0 gy dhkey))))
  (label 3)
  (parent 2)
  (unrealized (1 2))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy gy-0 gx-0 akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy-0))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx-0) (gy gy))
  (deflistener (enc "dh" gx-0 gy dhkey))
  (defstrand CDHcalc2 2 (dhkey dhkey) (gx gx-0) (gy gy))
  (deflistener (enc "dh" gx gy-0 dhkey))
  (precedes ((0 0) (4 0)) ((0 2) (1 2)) ((1 1) (3 0)) ((2 1) (1 2))
    ((3 1) (2 0)) ((4 1) (1 2)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (operation nonce-test (added-listener (enc "dh" gx gy-0 dhkey)) n
    (1 2) (enc n (enc "dh" gx gy-0 dhkey)))
  (traces
    ((send gx) (recv gy-0) (send (enc n (enc "dh" gx gy-0 dhkey))))
    ((recv gx-0) (send gy) (recv (enc n (enc "dh" gx-0 gy dhkey))))
    ((recv (enc "dh" gx-0 gy dhkey)) (send (enc "dh" gx-0 gy dhkey)))
    ((recv (cat gy (invk gx-0))) (send (enc "dh" gx-0 gy dhkey)))
    ((recv (enc "dh" gx gy-0 dhkey)) (send (enc "dh" gx gy-0 dhkey))))
  (label 4)
  (parent 3)
  (unrealized (4 0))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy gy-0 gx-0 akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy-0))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx-0) (gy gy))
  (deflistener (enc "dh" gx-0 gy dhkey))
  (defstrand CDHcalc2 2 (dhkey dhkey) (gx gx-0) (gy gy))
  (deflistener (enc "dh" gx gy-0 dhkey))
  (defstrand CDHcalc1 2 (dhkey dhkey) (gx gx) (gy gy-0))
  (precedes ((0 0) (5 0)) ((0 2) (1 2)) ((1 1) (3 0)) ((2 1) (1 2))
    ((3 1) (2 0)) ((4 1) (1 2)) ((5 1) (4 0)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (operation encryption-test (added-strand CDHcalc1 2)
    (enc "dh" gx gy-0 dhkey) (4 0))
  (traces
    ((send gx) (recv gy-0) (send (enc n (enc "dh" gx gy-0 dhkey))))
    ((recv gx-0) (send gy) (recv (enc n (enc "dh" gx-0 gy dhkey))))
    ((recv (enc "dh" gx-0 gy dhkey)) (send (enc "dh" gx-0 gy dhkey)))
    ((recv (cat gy (invk gx-0))) (send (enc "dh" gx-0 gy dhkey)))
    ((recv (enc "dh" gx gy-0 dhkey)) (send (enc "dh" gx gy-0 dhkey)))
    ((recv (cat gx (invk gy-0))) (send (enc "dh" gx gy-0 dhkey))))
  (label 5)
  (parent 4)
  (unrealized)
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy gy-0 gx-0 akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy-0))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx-0) (gy gy))
  (defstrand CDHcalc2 2 (dhkey dhkey) (gx gx-0) (gy gy))
  (deflistener (enc "dh" gx gy-0 dhkey))
  (defstrand CDHcalc1 2 (dhkey dhkey) (gx gx) (gy gy-0))
  (precedes ((0 0) (4 0)) ((0 2) (1 2)) ((1 1) (2 0)) ((2 1) (1 2))
    ((3 1) (1 2)) ((4 1) (3 0)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (operation generalization deleted (2 0))
  (traces
    ((send gx) (recv gy-0) (send (enc n (enc "dh" gx gy-0 dhkey))))
    ((recv gx-0) (send gy) (recv (enc n (enc "dh" gx-0 gy dhkey))))
    ((recv (cat gy (invk gx-0))) (send (enc "dh" gx-0 gy dhkey)))
    ((recv (enc "dh" gx gy-0 dhkey)) (send (enc "dh" gx gy-0 dhkey)))
    ((recv (cat gx (invk gy-0))) (send (enc "dh" gx gy-0 dhkey))))
  (label 6)
  (parent 5)
  (unrealized)
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dh_mim
  (vars (dhkey skey) (n text) (gx gy gy-0 gx-0 akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (gy gy-0))
  (defstrand resp 3 (dhkey dhkey) (n n) (gx gx-0) (gy gy))
  (defstrand CDHcalc2 2 (dhkey dhkey) (gx gx-0) (gy gy))
  (defstrand CDHcalc1 2 (dhkey dhkey) (gx gx) (gy gy-0))
  (precedes ((0 0) (3 0)) ((0 2) (1 2)) ((1 1) (2 0)) ((2 1) (1 2))
    ((3 1) (1 2)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gx gy)
  (operation generalization deleted (3 0))
  (traces
    ((send gx) (recv gy-0) (send (enc n (enc "dh" gx gy-0 dhkey))))
    ((recv gx-0) (send gy) (recv (enc n (enc "dh" gx-0 gy dhkey))))
    ((recv (cat gy (invk gx-0))) (send (enc "dh" gx-0 gy dhkey)))
    ((recv (cat gx (invk gy-0))) (send (enc "dh" gx gy-0 dhkey))))
  (label 7)
  (parent 6)
  (unrealized)
  (shape)
  (maps
    ((0 1)
      ((n n) (gx gx) (gy gy) (dhkey dhkey) (gy-0 gy-0) (gx-0 gx-0))))
  (origs (gy (1 1)) (gx (0 0)) (n (0 2))))

(comment "Nothing left to do")
