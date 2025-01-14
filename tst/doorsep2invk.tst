(herald doorsep2invk (comment "Door Simple Example Protocol"))

(comment "CPSA 4.3.0")
(comment "All input read from tst/doorsep2invk.scm")

(defprotocol doorsep basic
  (defrole init
    (vars (self peer akey) (skey skey) (data text))
    (trace (send (enc (enc skey (invk self)) peer))
      (recv (enc data skey)) (send data))
    (uniq-orig skey))
  (defrole resp
    (vars (self peer akey) (skey skey) (data text))
    (trace (recv (enc (enc skey (invk peer)) self))
      (send (enc data skey)) (recv data))
    (uniq-orig data))
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
  (comment "Doorsep's protocol using unnamed asymmetric keys"))

(defskeleton doorsep
  (vars (skey+0 skey) (text+0 text) (akey+1 akey+0 akey+3 akey))
  (defstrand init 1 (skey skey+0) (self (invk akey+3)) (peer akey+0))
  (defstrand resp 3 (skey skey+0) (data text+0) (self akey+1)
    (peer (invk akey+3)))
  (precedes ((0 0) (1 0)))
  (non-orig akey+3 (invk akey+0))
  (uniq-orig skey+0 text+0)
  (goals
    (forall
      ((text+0 text) (skey+0 skey) (akey+1 akey+0 akey+3 akey)
        (z z-0 strd))
      (implies
        (and (p "resp" z 3) (p "init" z-0 1) (p "resp" "data" z text+0)
          (p "resp" "skey" z skey+0) (p "resp" "self" z akey+1)
          (p "resp" "peer" z (invk akey+3)) (p "init" "skey" z-0 skey+0)
          (p "init" "self" z-0 (invk akey+3))
          (p "init" "peer" z-0 akey+0) (prec z-0 0 z 0) (non akey+3)
          (non (invk akey+0)) (uniq-at skey+0 z-0 0)
          (uniq-at text+0 z 1)) (and))))
  (traces ((send (enc (enc skey+0 akey+3) akey+0)))
    ((recv (enc (enc skey+0 akey+3) akey+1)) (send (enc text+0 skey+0))
      (recv text+0)))
  (label 0)
  (unrealized (1 0) (1 2))
  (origs (skey+0 (0 0)) (text+0 (1 1)))
  (comment "1 in cohort - 1 not yet seen"))

(defskeleton doorsep
  (vars (skey+0 skey) (text+0 text) (akey+0 akey+3 akey))
  (defstrand init 1 (skey skey+0) (self (invk akey+3)) (peer akey+0))
  (defstrand resp 3 (skey skey+0) (data text+0) (self akey+0)
    (peer (invk akey+3)))
  (precedes ((0 0) (1 0)))
  (non-orig akey+3 (invk akey+0))
  (uniq-orig skey+0 text+0)
  (operation encryption-test (contracted (akey+1 akey+0))
    (enc skey+0 akey+3) (1 0) (enc (enc skey+0 akey+3) akey+0))
  (traces ((send (enc (enc skey+0 akey+3) akey+0)))
    ((recv (enc (enc skey+0 akey+3) akey+0)) (send (enc text+0 skey+0))
      (recv text+0)))
  (label 1)
  (parent 0)
  (unrealized (1 2))
  (origs (skey+0 (0 0)) (text+0 (1 1)))
  (comment "2 in cohort - 2 not yet seen"))

(defskeleton doorsep
  (vars (skey+0 skey) (text+0 text) (self peer akey))
  (defstrand resp 3 (skey skey+0) (data text+0) (self peer) (peer self))
  (defstrand init 3 (skey skey+0) (data text+0) (self self) (peer peer))
  (precedes ((0 1) (1 1)) ((1 0) (0 0)) ((1 2) (0 2)))
  (non-orig (invk self) (invk peer))
  (uniq-orig skey+0 text+0)
  (operation nonce-test (displaced 0 2 init 3) text+0 (1 2)
    (enc text+0 skey+0))
  (traces
    ((recv (enc (enc skey+0 (invk self)) peer))
      (send (enc text+0 skey+0)) (recv text+0))
    ((send (enc (enc skey+0 (invk self)) peer))
      (recv (enc text+0 skey+0)) (send text+0)))
  (label 2)
  (parent 1)
  (unrealized)
  (shape)
  (satisfies yes)
  (maps
    ((1 0)
      ((text+0 text+0) (skey+0 skey+0) (akey+1 peer) (akey+0 peer)
        (akey+3 (invk self)))))
  (origs (skey+0 (1 0)) (text+0 (0 1))))

(defskeleton doorsep
  (vars (skey+0 skey) (text+0 text) (akey+0 akey+3 akey))
  (defstrand init 1 (skey skey+0) (self (invk akey+3)) (peer akey+0))
  (defstrand resp 3 (skey skey+0) (data text+0) (self akey+0)
    (peer (invk akey+3)))
  (deflistener skey+0)
  (precedes ((0 0) (1 0)) ((0 0) (2 0)) ((2 1) (1 2)))
  (non-orig akey+3 (invk akey+0))
  (uniq-orig skey+0 text+0)
  (operation nonce-test (added-listener skey+0) text+0 (1 2)
    (enc text+0 skey+0))
  (traces ((send (enc (enc skey+0 akey+3) akey+0)))
    ((recv (enc (enc skey+0 akey+3) akey+0)) (send (enc text+0 skey+0))
      (recv text+0)) ((recv skey+0) (send skey+0)))
  (label 3)
  (parent 1)
  (unrealized (2 0))
  (dead)
  (comment "empty cohort"))

(comment "Nothing left to do")
