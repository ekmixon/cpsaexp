(herald dhencrypt (algebra basic))

(comment "CPSA 4.3.0")
(comment "All input read from tst/dh_encrypt_hack.scm")

(defprotocol dhencrypt basic
  (defrole init
    (vars (gx h akey) (dhkey skey) (n text))
    (trace (send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey))))
    (non-orig dhkey (invk gx)))
  (defrole resp
    (vars (h gy akey) (dhkey skey) (n text))
    (trace (recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey))))
    (non-orig dhkey (invk gy))
    (uniq-orig n gy))
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
  (comment
    "Diffie-hellman key exchange followed by an encrypted-nonce challenge/response"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gx h akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (h h))
  (non-orig dhkey (invk gx))
  (comment "Initiator full point of view")
  (traces
    ((send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey)))))
  (label 0)
  (unrealized (0 1))
  (origs)
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gx h akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (h h))
  (defstrand resp 2 (dhkey dhkey) (n n) (h gx) (gy h))
  (precedes ((1 1) (0 1)))
  (non-orig dhkey (invk gx) (invk h))
  (uniq-orig n h)
  (operation encryption-test (added-strand resp 2)
    (enc n (enc "dh" gx h dhkey)) (0 1))
  (traces
    ((send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey))))
    ((recv gx) (send (cat h (enc n (enc "dh" gx h dhkey))))))
  (label 1)
  (parent 0)
  (unrealized)
  (shape)
  (maps ((0) ((gx gx) (h h) (dhkey dhkey) (n n))))
  (origs (h (1 1)) (n (1 1))))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gx h akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (h h))
  (deflistener (enc "dh" gx h dhkey))
  (precedes ((1 1) (0 1)))
  (non-orig dhkey (invk gx))
  (operation encryption-test (added-listener (enc "dh" gx h dhkey))
    (enc n (enc "dh" gx h dhkey)) (0 1))
  (traces
    ((send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey))))
    ((recv (enc "dh" gx h dhkey)) (send (enc "dh" gx h dhkey))))
  (label 2)
  (parent 0)
  (unrealized (1 0))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gx h akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (h h))
  (deflistener (enc "dh" gx h dhkey))
  (defstrand CDHcalc1 2 (dhkey dhkey) (gx gx) (gy h))
  (precedes ((1 1) (0 1)) ((2 1) (1 0)))
  (non-orig dhkey (invk gx))
  (operation encryption-test (added-strand CDHcalc1 2)
    (enc "dh" gx h dhkey) (1 0))
  (traces
    ((send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey))))
    ((recv (enc "dh" gx h dhkey)) (send (enc "dh" gx h dhkey)))
    ((recv (cat gx (invk h))) (send (enc "dh" gx h dhkey))))
  (label 3)
  (parent 2)
  (unrealized)
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gx h akey))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (h h))
  (defstrand CDHcalc1 2 (dhkey dhkey) (gx gx) (gy h))
  (precedes ((1 1) (0 1)))
  (non-orig dhkey (invk gx))
  (operation generalization deleted (1 0))
  (traces
    ((send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey))))
    ((recv (cat gx (invk h))) (send (enc "dh" gx h dhkey))))
  (label 4)
  (parent 3)
  (unrealized)
  (shape)
  (maps ((0) ((gx gx) (h h) (dhkey dhkey) (n n))))
  (origs))

(comment "Nothing left to do")

(defprotocol dhencrypt basic
  (defrole init
    (vars (gx h akey) (dhkey skey) (n text))
    (trace (send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey))))
    (non-orig dhkey (invk gx)))
  (defrole resp
    (vars (h gy akey) (dhkey skey) (n text))
    (trace (recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey))))
    (non-orig dhkey (invk gy))
    (uniq-orig n gy))
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
  (comment
    "Diffie-hellman key exchange followed by an encrypted-nonce challenge/response"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gy h akey))
  (defstrand resp 3 (dhkey dhkey) (n n) (h h) (gy gy))
  (non-orig dhkey (invk gy))
  (uniq-orig n gy)
  (comment "Responder full point of view")
  (traces
    ((recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey)))))
  (label 5)
  (unrealized (0 2))
  (origs (n (0 1)) (gy (0 1)))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gy h akey))
  (defstrand resp 3 (dhkey dhkey) (n n) (h h) (gy gy))
  (defstrand init 3 (dhkey dhkey) (n n) (gx h) (h gy))
  (precedes ((0 1) (1 1)) ((1 2) (0 2)))
  (non-orig dhkey (invk gy) (invk h))
  (uniq-orig n gy)
  (operation encryption-test (added-strand init 3)
    (enc "check" n (enc "dh" h gy dhkey)) (0 2))
  (traces
    ((recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey))))
    ((send h) (recv (cat gy (enc n (enc "dh" h gy dhkey))))
      (send (enc "check" n (enc "dh" h gy dhkey)))))
  (label 6)
  (parent 5)
  (unrealized)
  (shape)
  (maps ((0) ((gy gy) (h h) (dhkey dhkey) (n n))))
  (origs (n (0 1)) (gy (0 1))))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gy h akey))
  (defstrand resp 3 (dhkey dhkey) (n n) (h h) (gy gy))
  (deflistener (enc "dh" h gy dhkey))
  (precedes ((0 1) (1 0)) ((1 1) (0 2)))
  (non-orig dhkey (invk gy))
  (uniq-orig n gy)
  (operation encryption-test (added-listener (enc "dh" h gy dhkey))
    (enc "check" n (enc "dh" h gy dhkey)) (0 2))
  (traces
    ((recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey))))
    ((recv (enc "dh" h gy dhkey)) (send (enc "dh" h gy dhkey))))
  (label 7)
  (parent 5)
  (unrealized (1 0))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gy h akey))
  (defstrand resp 3 (dhkey dhkey) (n n) (h h) (gy gy))
  (deflistener (enc "dh" h gy dhkey))
  (defstrand CDHcalc2 2 (dhkey dhkey) (gx h) (gy gy))
  (precedes ((0 1) (2 0)) ((1 1) (0 2)) ((2 1) (1 0)))
  (non-orig dhkey (invk gy))
  (uniq-orig n gy)
  (operation encryption-test (added-strand CDHcalc2 2)
    (enc "dh" h gy dhkey) (1 0))
  (traces
    ((recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey))))
    ((recv (enc "dh" h gy dhkey)) (send (enc "dh" h gy dhkey)))
    ((recv (cat gy (invk h))) (send (enc "dh" h gy dhkey))))
  (label 8)
  (parent 7)
  (unrealized)
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gy h akey))
  (defstrand resp 3 (dhkey dhkey) (n n) (h h) (gy gy))
  (defstrand CDHcalc2 2 (dhkey dhkey) (gx h) (gy gy))
  (precedes ((0 1) (1 0)) ((1 1) (0 2)))
  (non-orig dhkey (invk gy))
  (uniq-orig n gy)
  (operation generalization deleted (1 0))
  (traces
    ((recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey))))
    ((recv (cat gy (invk h))) (send (enc "dh" h gy dhkey))))
  (label 9)
  (parent 8)
  (unrealized)
  (shape)
  (maps ((0) ((gy gy) (h h) (dhkey dhkey) (n n))))
  (origs (n (0 1)) (gy (0 1))))

(comment "Nothing left to do")

(defprotocol dhencrypt basic
  (defrole init
    (vars (gx h akey) (dhkey skey) (n text))
    (trace (send gx) (recv (cat h (enc n (enc "dh" gx h dhkey))))
      (send (enc "check" n (enc "dh" gx h dhkey))))
    (non-orig dhkey (invk gx)))
  (defrole resp
    (vars (h gy akey) (dhkey skey) (n text))
    (trace (recv h) (send (cat gy (enc n (enc "dh" h gy dhkey))))
      (recv (enc "check" n (enc "dh" h gy dhkey))))
    (non-orig dhkey (invk gy))
    (uniq-orig n gy))
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
  (comment
    "Diffie-hellman key exchange followed by an encrypted-nonce challenge/response"))

(defskeleton dhencrypt
  (vars (dhkey dhkey-0 skey) (n text) (gx gy akey))
  (defstrand init 2 (dhkey dhkey) (n n) (gx gx) (h gy))
  (defstrand resp 3 (dhkey dhkey-0) (n n) (h gx) (gy gy))
  (non-orig dhkey dhkey-0 (invk gx) (invk gy))
  (uniq-orig n gy)
  (comment
    "Point of view where the natural result should be the only shape")
  (traces ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey)))))
    ((recv gx) (send (cat gy (enc n (enc "dh" gx gy dhkey-0))))
      (recv (enc "check" n (enc "dh" gx gy dhkey-0)))))
  (label 10)
  (unrealized (0 1) (1 2))
  (preskeleton)
  (origs (n (1 1)) (gy (1 1)))
  (comment "Not a skeleton"))

(defskeleton dhencrypt
  (vars (dhkey dhkey-0 skey) (n text) (gx gy akey))
  (defstrand init 2 (dhkey dhkey) (n n) (gx gx) (h gy))
  (defstrand resp 3 (dhkey dhkey-0) (n n) (h gx) (gy gy))
  (precedes ((1 1) (0 1)))
  (non-orig dhkey dhkey-0 (invk gx) (invk gy))
  (uniq-orig n gy)
  (traces ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey)))))
    ((recv gx) (send (cat gy (enc n (enc "dh" gx gy dhkey-0))))
      (recv (enc "check" n (enc "dh" gx gy dhkey-0)))))
  (label 11)
  (parent 10)
  (unrealized (0 1) (1 2))
  (origs (n (1 1)) (gy (1 1)))
  (comment "3 in cohort - 3 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gx gy akey))
  (defstrand resp 3 (dhkey dhkey) (n n) (h gx) (gy gy))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (h gy))
  (precedes ((0 1) (1 1)) ((1 2) (0 2)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gy)
  (operation encryption-test (displaced 0 2 init 3)
    (enc "check" n (enc "dh" gx gy dhkey)) (1 2))
  (traces
    ((recv gx) (send (cat gy (enc n (enc "dh" gx gy dhkey))))
      (recv (enc "check" n (enc "dh" gx gy dhkey))))
    ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey))))
      (send (enc "check" n (enc "dh" gx gy dhkey)))))
  (label 12)
  (parent 11)
  (unrealized)
  (shape)
  (maps ((1 0) ((gx gx) (gy gy) (n n) (dhkey dhkey) (dhkey-0 dhkey))))
  (origs (n (0 1)) (gy (0 1))))

(defskeleton dhencrypt
  (vars (dhkey dhkey-0 skey) (n text) (gx gy akey))
  (defstrand init 2 (dhkey dhkey) (n n) (gx gx) (h gy))
  (defstrand resp 3 (dhkey dhkey-0) (n n) (h gx) (gy gy))
  (defstrand init 3 (dhkey dhkey-0) (n n) (gx gx) (h gy))
  (precedes ((1 1) (0 1)) ((1 1) (2 1)) ((2 2) (1 2)))
  (non-orig dhkey dhkey-0 (invk gx) (invk gy))
  (uniq-orig n gy)
  (operation encryption-test (added-strand init 3)
    (enc "check" n (enc "dh" gx gy dhkey-0)) (1 2))
  (traces ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey)))))
    ((recv gx) (send (cat gy (enc n (enc "dh" gx gy dhkey-0))))
      (recv (enc "check" n (enc "dh" gx gy dhkey-0))))
    ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey-0))))
      (send (enc "check" n (enc "dh" gx gy dhkey-0)))))
  (label 13)
  (parent 11)
  (unrealized (0 1))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton dhencrypt
  (vars (dhkey dhkey-0 skey) (n text) (gx gy akey))
  (defstrand init 2 (dhkey dhkey) (n n) (gx gx) (h gy))
  (defstrand resp 3 (dhkey dhkey-0) (n n) (h gx) (gy gy))
  (deflistener (enc "dh" gx gy dhkey-0))
  (precedes ((1 1) (0 1)) ((1 1) (2 0)) ((2 1) (1 2)))
  (non-orig dhkey dhkey-0 (invk gx) (invk gy))
  (uniq-orig n gy)
  (operation encryption-test (added-listener (enc "dh" gx gy dhkey-0))
    (enc "check" n (enc "dh" gx gy dhkey-0)) (1 2))
  (traces ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey)))))
    ((recv gx) (send (cat gy (enc n (enc "dh" gx gy dhkey-0))))
      (recv (enc "check" n (enc "dh" gx gy dhkey-0))))
    ((recv (enc "dh" gx gy dhkey-0)) (send (enc "dh" gx gy dhkey-0))))
  (label 14)
  (parent 11)
  (unrealized (0 1) (2 0))
  (dead)
  (comment "empty cohort"))

(defskeleton dhencrypt
  (vars (dhkey skey) (n text) (gx gy akey))
  (defstrand init 2 (dhkey dhkey) (n n) (gx gx) (h gy))
  (defstrand resp 3 (dhkey dhkey) (n n) (h gx) (gy gy))
  (defstrand init 3 (dhkey dhkey) (n n) (gx gx) (h gy))
  (precedes ((1 1) (0 1)) ((1 1) (2 1)) ((2 2) (1 2)))
  (non-orig dhkey (invk gx) (invk gy))
  (uniq-orig n gy)
  (operation encryption-test (displaced 3 1 resp 2)
    (enc n (enc "dh" gx gy dhkey-0)) (0 1))
  (traces ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey)))))
    ((recv gx) (send (cat gy (enc n (enc "dh" gx gy dhkey))))
      (recv (enc "check" n (enc "dh" gx gy dhkey))))
    ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey))))
      (send (enc "check" n (enc "dh" gx gy dhkey)))))
  (label 15)
  (parent 13)
  (unrealized)
  (shape)
  (maps ((0 1) ((gx gx) (gy gy) (n n) (dhkey dhkey) (dhkey-0 dhkey))))
  (origs (gy (1 1)) (n (1 1))))

(defskeleton dhencrypt
  (vars (dhkey dhkey-0 skey) (n text) (gx gy akey))
  (defstrand init 2 (dhkey dhkey) (n n) (gx gx) (h gy))
  (defstrand resp 3 (dhkey dhkey-0) (n n) (h gx) (gy gy))
  (defstrand init 3 (dhkey dhkey-0) (n n) (gx gx) (h gy))
  (deflistener (enc "dh" gx gy dhkey))
  (precedes ((1 1) (2 1)) ((1 1) (3 0)) ((2 2) (1 2)) ((3 1) (0 1)))
  (non-orig dhkey dhkey-0 (invk gx) (invk gy))
  (uniq-orig n gy)
  (operation encryption-test (added-listener (enc "dh" gx gy dhkey))
    (enc n (enc "dh" gx gy dhkey)) (0 1))
  (traces ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey)))))
    ((recv gx) (send (cat gy (enc n (enc "dh" gx gy dhkey-0))))
      (recv (enc "check" n (enc "dh" gx gy dhkey-0))))
    ((send gx) (recv (cat gy (enc n (enc "dh" gx gy dhkey-0))))
      (send (enc "check" n (enc "dh" gx gy dhkey-0))))
    ((recv (enc "dh" gx gy dhkey)) (send (enc "dh" gx gy dhkey))))
  (label 16)
  (parent 13)
  (unrealized (0 1) (3 0))
  (dead)
  (comment "empty cohort"))

(comment "Nothing left to do")
