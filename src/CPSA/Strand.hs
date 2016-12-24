-- Instance and preskeleton data structures and support functions.

-- Copyright (c) 2009 The MITRE Corporation
--
-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the BSD License as published by the
-- University of California.

module CPSA.Strand (Instance, mkInstance, bldInstance, mkListener,
    role, env, trace, height, listenerTerm, Sid, Node, mkPreskel,
    firstSkeleton, Pair, Preskel, gen, protocol, kgoals, insts, orderings,
    pov, knon, kpnon, kunique, korig, kpriority, kcomment, nstrands, kvars,
    strandids, kterms, uniqOrig, preskelWellFormed, verbosePreskelWellFormed,
    Strand, inst, sid, nodes, Vertex, strand, pos, preds, event,
    graphNode, strands, vertex, Gist, gist, isomorphic, contract, augment,
    inheritRnon, inheritRpnon, inheritRunique, addListener, Cause
    (..), Direction (..), Method (..), Operation (..), operation,
    prob, homomorphism, toSkeleton, generalize, collapse, sat) where

import Control.Monad
import qualified Data.List as L
import qualified Data.Set as S
import Data.Set (Set)
import qualified Data.Maybe as M
import CPSA.Lib.Utilities
import CPSA.Lib.SExpr
import CPSA.Algebra
import CPSA.Protocol
import CPSA.Goal

{--
import System.IO.Unsafe
import Control.Exception (try)
import System.IO.Error (ioeGetErrorString)

z :: Show a => a -> b -> b
z x y = unsafePerformIO (print x >> return y)

zz :: Show a => a -> a
zz x = z x x

zb :: Show a => a -> Bool -> Bool
zb a False = z a False
zb _ b = b

zn :: Show a => a -> Maybe b -> Maybe b
zn x Nothing = z x Nothing
zn _ y = y

zf :: Show a => a -> Bool -> Bool
zf x False = z x False
zf _ y = y

zt :: Show a => a -> Bool -> Bool
zt x True = z x True
zt _ y = y

zl :: Show a => [a] -> [a]
zl a = z (length a) a

zi :: Algebra t p g s e c => Instance t e -> String
zi inst =
    show (map f e)
    where
      domain = rvars (role inst)
      e = reify domain (env inst)
      range = map snd e
      f (x, t) = (displayTerm (context domain) x,
                  displayTerm (context range) t)
      context ts = addToContext emptyContext ts

zv :: Algebra t p g s e c => Preskel t g s e -> String
zv k =
  unsafePerformIO $ do
    y <- try $ verbosePreskelWellFormed k
    case y of
      Right _ ->
        return "preskel well formed"
      Left err ->
        return $ ioeGetErrorString err

-- Also see showst
--}

-- Compile time switches for expermentation.

-- Do not do multistrand thinning.
useSingleStrandThinning :: Bool
useSingleStrandThinning = False -- True

-- Sanity check: ensure no role variable occurs in a skeleton.
useCheckVars :: Bool
useCheckVars = False

useThinningDuringCollapsing :: Bool
useThinningDuringCollapsing = False -- True

useThinningWhileSolving :: Bool
useThinningWhileSolving = True -- False

useNoOrigPreservation :: Bool
useNoOrigPreservation = False -- True

-- Instances and Strand Identifiers

-- An Instance is an instance of a role, in the sense that each
-- variable in the role's trace has been replaced by a term.  The
-- trace of the instance might be shorter that the role's trace, but
-- only truncating nodes from the end of the trace.

-- A preskeleton stores its strands as a ordered sequence of
-- instances.  A strand is the position of an instance in the
-- sequence.  Duplicates are allowed in the sequence, as two strands
-- can be instantiated from the same role in the same way.

type Sid = Int                  -- Strand Identifier

data Instance = Instance
    { role :: Role,             -- Role from which this was
                                -- instantiated

      env :: !Env,              -- The environment used to build this
                                -- instance's trace from its role's
                                -- trace

      trace :: !Trace,          -- Instance's trace

      height :: !Int }          -- Height of the instance
    deriving Show

-- Create a fresh instance of the given height.  The environment
-- specifies how to map some variables in the role's trace.  Unmapped
-- variables are instantiated with fresh variables to avoid naming
-- conflicts.
mkInstance :: Gen -> Role -> Env -> Int -> (Gen, Instance)
mkInstance gen role env height =
    let trace = rtrace role
        rheight = length trace in
    if height < 1 || height > rheight then
        error "Strand.mkInstance: Bad strand height"
    else
        let (gen', env') = grow (rvars role) gen env
            trace' = map (evtMap $ instantiate env') (take height trace) in
        -- Ensure every variable in the range of the environment
        -- occurs in the trace.
        case bldInstance role trace' gen' of
          (gen'', inst) : _ -> (gen'', inst)
          [] -> error "Strand.mkInstance: Not an instance"

-- For each term that matches itself in the environment, extend the
-- mapping so that the term maps to one with a fresh set of variables.
-- It is an error if a variable in one of the terms is explicitly
-- mapped to itself in the initial environment.
grow :: [Term] -> Gen -> Env -> (Gen, Env)
grow [] gen env = (gen, env)
grow (t : ts) gen env =
    case match t t (gen, env) of
      [] -> grow ts gen env     -- Term already mapped
      _ ->                      -- Otherwise make a fresh mapping
          let (gen', t') = clone gen t in
          case match t t' (gen', env) of
            (gen'', env') : _ -> grow ts gen'' env'
            [] -> error "Strand.grow: Internal error"

-- Build an instance from a role and a trace.  Returns the empty list
-- if the trace is not an instance of the given role.
bldInstance :: Role -> Trace -> Gen -> [(Gen, Instance)]
bldInstance _ [] _ = error "Strand.bldInstance: Bad trace"
bldInstance role trace gen =
    loop (rtrace role) trace (gen, emptyEnv) -- Loop builds env
    where
      loop _ [] (gen, env) =        -- Trace can be shorter than role's trace
          [(gen, makeInstance role env trace)]
      loop (In t : c) (In t' : c') ge =
          do
            env <- match t t' ge
            loop c c' env
      loop (Out t : c) (Out t' : c') ge =
          do
            env <- match t t' ge
            loop c c' env
      loop _ _ _ = []

makeInstance :: Role -> Env -> Trace -> Instance
makeInstance role env trace =
    Instance { role = role,
               env = env,
               trace = trace,
               height = length trace }

mkListener :: Prot -> Gen -> Term -> (Gen, Instance)
mkListener p gen term =
    case bldInstance (listenerRole p) [In term, Out term] gen of
      [x] -> x
      _ -> error "Strand.mkListener: Cannot build an instance of a listener"

-- Add to set s the variables that are in the range of instance i
addIvars :: Set Term -> Instance -> Set Term
addIvars s i =
    foldl g s (reify (rvars (role i)) (env i))
    where
      g s (_, t) = foldVars (flip S.insert) s t

listenerTerm :: Instance -> Maybe Term
listenerTerm inst =
    case rname (role inst) of
      "" -> inbnd (trace inst !! 0) -- Get first term in trace
      _ -> Nothing              -- Not a listener strand

-- Nodes, Pairs, and Graphs

-- A node is composed of two integers, a strand identifier and a
-- position.  The position identifies an event in the strand's trace.
-- The second integer must be non-negative and less than the strand's
-- height

type Node = (Sid, Int)

-- A pair gives an ordering of two nodes, meaning the first node is
-- before the second one.

type Pair = (Node, Node)

-- Graphs of preskeletons

-- A strand is what is referred to by a strand ID.

data GraphStrand e i                 -- e for event, i for instance
    = GraphStrand { inst :: i,
                    nodes :: [GraphNode e i],
                    sid :: Sid }

-- The Strand ID determines equality and orderings
instance Eq (GraphStrand e i) where
    s0 == s1 = sid s0 == sid s1

instance Ord (GraphStrand e i) where
    compare s0 s1 = compare (sid s0) (sid s1)

instance Show (GraphStrand e i) where
    showsPrec _ s = shows (sid s)

-- A vertex is what is referred to by a node.

data GraphNode e i                 -- e for event, i for instance
    = GraphNode { event :: e,
                  preds :: [GraphNode e i], -- Immediate preds including
                  strand :: GraphStrand e i,  -- strand succession edges
                  pos :: Int }  -- The position of the node in the strand

-- The node determines equality and orderings
instance Eq (GraphNode e i) where
    n0 == n1 = (strand n0, pos n0) == (strand n1, pos n1)

instance Ord (GraphNode e i) where
    compare n0 n1 = compare (strand n0, pos n0) (strand n1, pos n1)

instance Show (GraphNode e i) where
    showsPrec _ n = let (s, i') = graphNode n in
                    showChar '(' . shows s . showString ", " .
                    shows i' . showChar ')'

-- The node of a vertex
graphNode :: GraphNode e i -> Node
graphNode n = (sid (strand n), pos n)

type GraphEdge e i = (GraphNode e i, GraphNode e i)

-- The pair of an edge
graphPair :: GraphEdge e i -> Pair
graphPair (n0, n1) = (graphNode n0, graphNode n1)

graphEdges :: [GraphStrand e i] -> [GraphEdge e i]
graphEdges strands =
    [ (dst, src) | s <- strands, src <- nodes s, dst <- preds src ]

data Graph e i
    = Graph { gstrands :: [GraphStrand e i],
              gedges :: [GraphEdge e i] }

-- The graph associated with a preskeleton
graph :: (i -> [d]) -> (i -> Int) -> [i] -> [Pair] -> Graph d i
graph trace height insts pairs =
    Graph { gstrands = strands,
            gedges = map getEdge pairs }
    where
      strands = [ GraphStrand { inst = inst,
                                nodes = nodes !! sid,
                                sid = sid } |
                  (sid, inst) <- zip [0..] insts ]
      nodes = [ [ GraphNode { event = trace (inst strand) !! pos,
                              preds = preds (sid, pos),
                              strand = strand,
                              pos = pos } |
                  pos <- nats (height (inst strand)) ] |
                (sid, strand) <- zip [0..] strands ]
      preds n = map getNode (entry n)
      getNode (s, i) = nodes !! s !! i
      getEdge (n0, n1) = (getNode n0, getNode n1)
      entry n = enrich n [ n0 | (n0, n1) <- pairs, n1 == n ]
      -- add strand succession edges
      enrich (s, i) ns
          | i > 0 = (s, i - 1) : ns
          | otherwise = ns

-- Compute the transitive reduction
graphReduce :: [GraphEdge e i] -> [GraphEdge e i]
graphReduce orderings =
    filter essential orderings
    where
      essential (dst, src) =
          loop dst (L.delete dst (preds src)) [src]
      loop _ [] _ = True        -- No other path found
      loop dst (n : ns) seen
          | n == dst = False    -- There is another path
          | elem n seen = loop dst ns seen
          | otherwise = loop dst (preds n ++ ns) (n : seen)

-- Compute the transitive closure
-- This routine returns pairs that are not well ordered.
-- Deal with it!
graphClose :: [GraphEdge e i] -> [GraphEdge e i]
graphClose orderings =
    filter (not . sameStrands) (loop orderings False orderings)
    where
      loop orderings False [] = orderings
      loop orderings True [] =
          loop orderings False orderings -- restart loop
      loop orderings repeat ((n0, n1) : pairs) =
          inner orderings repeat pairs [(n, n1) | n <- preds n0]
      inner orderings repeat pairs [] =
          loop orderings repeat pairs
      inner orderings repeat pairs (p : rest)
          | elem p orderings = inner orderings repeat pairs rest
          | otherwise = inner (p : orderings) True pairs rest
      sameStrands (n0, n1) = strand n0 == strand n1

-- Shared part of preskeletons

data Shared = Shared
    { prot  :: Prot,
      goals :: [Goal] }

instance Show Shared where
    showsPrec _ s = shows (prot s)

protocol :: Preskel -> Prot
protocol k = prot $ shared k

kgoals :: Preskel -> [Goal]
kgoals k = goals $ shared k

-- Preskeletons

data Preskel = Preskel
    { gen :: !Gen,
      shared :: Shared,
      insts :: ![Instance],
      strands :: ![Strand],
      orderings :: ![Pair],
      edges :: ![Edge],
      knon :: ![Term],            -- A list of atoms
      kpnon :: ![Term],           -- A list of atoms
      kunique :: ![Term],         -- A list of atoms
      kpriority :: [(Node, Int)], -- Override node priority
      kcomment :: [SExpr ()],   -- Comments from the input
      korig :: ![(Term, [Node])], -- This is an association list with a
                                -- pair for each element of kunique.
                                -- The value associated with a term
                                -- is a list of the nodes at which it
                                -- originates--the term's provenance.
      pov :: Maybe Preskel,     -- Point of view, the
                                -- original problem statement.
      strandids :: ![Sid],
      tc :: [Pair],             -- Transitive closure of orderings
                                -- Used only during generalization
      operation :: Operation,
      prob :: [Sid] }        -- A map from the strands in the original
    deriving Show               -- problem statement, the pov, into
                                -- these strands.

-- The pov skeleton is the only skeleton that should have Nothing in
-- its pov field.

type Strand = GraphStrand Event Instance

type Vertex = GraphNode Event Instance

type Edge = GraphEdge Event Instance

-- Data structure for tracking the causes for the creation of
-- preskeletons.

data Cause
    = Cause Direction Node Term (Set Term)
    deriving Show

data Direction = Encryption | Nonce deriving Show

data Method
    = Deleted Node
    | Weakened Pair
    | Separated Term
    | Forgot Term deriving Show

-- The operation used to generate the preskeleteton is either new via
-- the loader, a contraction, a regular augmentation, a listener
-- augmentation, or a mininization.  The augmentation includes a role
-- name and instance height.
data Operation
    = New
    | Contracted Subst Cause
    | Displaced Int Int String Int Cause
    | AddedStrand String Int Cause
    | AddedListener Term Cause
    | Generalized Method
    | Collapsed Int Int
      deriving Show

-- Create a preskeleton.  The point of view field is not filled in.
-- This version is exported for use by the loader.  This preskeleton
-- must be consumed by firstSkeleton.
mkPreskel :: Gen -> Prot -> [Goal] ->
             [Instance] -> [Pair] -> [Term] -> [Term] -> [Term] ->
             [(Node, Int)] -> [SExpr ()] -> Preskel
mkPreskel gen protocol gs insts orderings non pnon unique prio comment =
    k { kcomment = comment }
    where
      k = newPreskel gen shared insts orderings non pnon
          unique prio New prob Nothing
      shared = Shared { prot = protocol, goals = gs }
      prob = strandids k        -- Fixed point on k is okay.

-- Strand functions

strandInst :: Preskel -> Sid -> Instance
strandInst k strand = insts k !! strand

nstrands :: Preskel -> Int
nstrands k = length (strandids k)

-- Convert the preskeleton made by the loader into the first skeleton
-- used in the search.
firstSkeleton :: Preskel -> [Preskel]
firstSkeleton k =
    do
      k <- wellFormedPreskel k
      k' <- toSkeleton False k   -- only k' should have pov = Nothing
      return $ k' { prob = strandids k', pov = Just k' }

-- Create a preskeleton.  The node ordering relation is put into the
-- preds field of each instance in this function.  The maybe uniquely
-- originating term data is also filled in.  This version is used
-- within this module.
newPreskel :: Gen -> Shared ->
             [Instance] -> [Pair] -> [Term] -> [Term] -> [Term] ->
             [(Node, Int)] -> Operation -> [Sid] ->
             Maybe Preskel -> Preskel
newPreskel gen shared insts orderings non pnon unique prio oper prob pov =
    let orderings' = L.nub orderings
        unique' = L.nub unique
        g = graph trace height insts orderings'
        strands = gstrands g
        edges = gedges g
        orig = map (originationNodes strands) unique'
        tc = filter pairWellOrdered (graphClose $ graphEdges strands)
        k = Preskel { gen = gen,
                      shared = shared,
                      insts = insts,
                      strands = strands,
                      orderings = orderings',
                      edges = edges,
                      knon = L.nub non,
                      kpnon = L.nub pnon,
                      kunique = unique',
                      kpriority = prio,
                      kcomment = [],
                      korig = orig,
                      tc = map graphPair tc,
                      strandids = nats (length insts),
                      operation = oper,
                      prob = prob,
                      pov = pov } in
        if useCheckVars then
            checkVars k
        else k

checkVars :: Preskel -> Preskel
checkVars k =
    foldl f k rolevars
    where
      skelvars = S.fromList $ kvars k
      rolevars = concatMap (rvars . role) (insts k)
      f k v
        | S.member v skelvars =
            error ("Strand.checkVars: role var in skel " ++ show k)
        | otherwise = k

vertex  :: Preskel -> Node -> Vertex
vertex k (s, i) =
    nodes (strands k !! s) !! i

originationNodes :: [Strand] -> Term -> (Term, [Node])
originationNodes strands u =
    (u, [ (sid strand, p) |
          strand <- reverse strands,
          p <- M.maybeToList $ originationPos u (trace (inst strand)) ])

uniqOrig :: Preskel -> [Term]
uniqOrig k =
    do
      (t, [_]) <- reverse (korig k)
      return t

-- A preskeleton is well formed if the ordering relation is acyclic,
-- each atom declared to be uniquely-originating is carried in some
-- preskeleton term, and every variable that occurs in each base term
-- declared to be non-originating or pen-non-originating occurs in
-- some preskeleton term, and the atom must never be carried by any
-- term, and every uniquely originating role term mapped by an
-- instance is mapped to a term that originates on the instance's
-- strand.

preskelWellFormed :: Preskel -> Bool
preskelWellFormed k =
    varSubset (knon k) terms &&
    varSubset (kpnon k) terms &&
    all nonCheck (knon k) &&
    all uniqueCheck (kunique k) &&
    wellOrdered k && acyclicOrder k &&
    roleOrigCheck k
    where
      terms = kterms k
      nonCheck t = all (not . carriedBy t) terms
      uniqueCheck t = any (carriedBy t) terms

-- Do notation friendly preskeleton well formed check.
wellFormedPreskel :: Monad m => Preskel -> m Preskel
wellFormedPreskel k
    | preskelWellFormed k = return k
    | otherwise = fail "preskeleton not well formed"

-- A version of preskelWellFormed that explains why a preskeleton is
-- not well formed.
verbosePreskelWellFormed :: Monad m => Preskel -> m ()
verbosePreskelWellFormed k =
    do
      failwith "a variable in non-orig is not in some trace"
                   $ varSubset (knon k) terms
      failwith "a variable in pen-non-orig is not in some trace"
                   $ varSubset (kpnon k) terms
      mapM_ nonCheck $ knon k
      mapM_ uniqueCheck $ kunique k
      failwith "ordered pairs not well formed" $ wellOrdered k
      failwith "cycle found in ordered pairs" $ acyclicOrder k
      failwith "an inherited unique doesn't originate in its strand"
                   $ roleOrigCheck k
    where
      terms = kterms k
      nonCheck t =
          failwith (showString "non-orig " $ showst t " carried")
                       $ all (not . carriedBy t) terms
      uniqueCheck t =
          failwith (showString "uniq-orig " $ showst t " not carried")
                       $ any (carriedBy t) terms

failwith :: Monad m => String -> Bool -> m ()
failwith msg test =
    case test of
      True -> return ()
      False -> fail msg

showst :: Term -> ShowS
showst t =
    shows $ displayTerm (addToContext emptyContext [t]) t

-- Do the nodes in the orderings have the right direction?
wellOrdered :: Preskel -> Bool
wellOrdered k =
    all pairWellOrdered (edges k)

pairWellOrdered :: Edge -> Bool
pairWellOrdered (n0, n1) =
    case (event n0, event n1) of
      (Out _, In _) -> True
      _ -> False

-- The terms used in the strands in this preskeleton.
-- Should this return a set, or a multiset?
kterms :: Preskel -> [Term]
kterms k = iterms (insts k)

-- The terms used in a list of instances.
iterms :: [Instance] -> [Term]
iterms insts =
  L.nub [evtTerm evt | i <- insts, evt <- trace i]

-- The node orderings form an acyclic order if there are no cycles.
-- Use depth first search to detect cycles.  A graph with no node with
-- an indegree of zero is cyclic and must not be checked with depth
-- first search.
acyclicOrder :: Preskel -> Bool
acyclicOrder k =
    all (not . backEdge numbering) edges
    where
      edges = graphEdges (strands k)
      -- The starting set contains the last node in every strand
      start = map (last . nodes) (strands k)
      -- Remove nodes that have non-zero indegree
      start' = foldl (flip L.delete) start (map fst edges)
      numbering = dfs preds start'

-- Variables in this preskeleton, excluding ones in roles, and ones
-- that only occur in a cause.
kvars :: Preskel -> [Term]
kvars k =
    S.elems $ foldl addIvars S.empty (insts k)

-- Ensure each role unique origination assumption mapped by an
-- instance originates in the instance's strand.
roleOrigCheck :: Preskel -> Bool
roleOrigCheck k =
    all strandRoleOrig (strands k) -- Check each strand
    where
      strandRoleOrig strand =   -- Check each role unique used in strand
          all (uniqRoleOrig strand) $ ruorig $ role $ inst strand
      uniqRoleOrig strand (ru, pos)
          | pos < height (inst strand) =
              case lookup (instantiate (env $ inst strand) ru) (korig k) of
                Nothing -> True     -- role term not mapped
                Just ns -> any (\(s, i)-> sid strand == s && i == pos) ns
          | otherwise = True

-- Isomorphism Check

-- Are two skeletons equivalent?  Two skeletons are equivalent if they
-- are isomorphic.  A key efficiency requirement in the implementation
-- of the cryptograhic protocol shapes analysis algorithm is to ensure
-- only one member of each equivalence class of skeletons is analyzed,
-- and the results of that analysis is immediately used for all other
-- members of the equivalence class.

-- To meet this requirement, a list of skeletons that have been seen
-- is maintained.  Before a skeleton is put on a to do list for
-- analysis, it is checked to see if it is ismorphic to one already
-- seen.  If so, the results of the analysis for the ismorphic
-- skeleton is used instead of putting the skeleton on the to do list.

-- Once a skeleton has been printed, the only reason for saving it is
-- for isomorphism checking.  The isomorphism check is performed
-- frequently, so an specialized data structure is used.  The gist of
-- a skeleton is all that is needed for the test for equivalence.

data Gist = Gist
    { ggen :: Gen,
      gtraces :: [(Int, Trace)],
      gorderings :: [Pair],
      gnon :: [Term],    -- A list of non-originating terms
      gpnon :: [Term],   -- A list of penetrator non-originating terms
      gunique :: [Term], -- A list of uniquely-originating terms
      nvars :: !Int,     -- Number of variables
      ntraces :: !Int,   -- Number of traces
      norderings :: !Int,       -- Number of orderings
      nnon :: !Int,             -- Number of non-originating terms
      npnon :: !Int,     -- Number of penetrator non-originating terms
      nunique :: !Int }        -- Number of uniquely-originating terms
    deriving Show

gist :: Preskel -> Gist
gist k =
    Gist { ggen = gen k,
           gtraces = gtraces,
           gorderings = gorderings,
           gnon = gnon,
           gpnon = gpnon,
           gunique = gunique,
           nvars = length (kvars k),
           ntraces = length gtraces,
           norderings = length gorderings,
           nnon = length gnon,
           npnon = length gpnon,
           nunique = length gunique }
    where
      gtraces = map (\i -> (height i, trace i)) (insts k)
      gorderings = orderings k
      gnon = knon k
      gpnon = kpnon k
      gunique = kunique k

-- Test to see if two preskeletons are isomorphic

-- First, ensure the two preskeletons have:
-- 1. The same number of variables
-- 2. The same number of strands
-- 3. The same number of node orderings
-- 4. The same number of terms in knon and kunique

-- Next compute the plausible permutations and substitutions.

-- Next, for each permutation of the strands, eliminate the ones that
-- map a strand to another of a different length, and don't cause the
-- node orderings to be equal.

-- For permutations that meet the previous conditions, see if there is
-- a renaming that maps every strand trace in one preskeleton into the
-- appropriate one in the other preskeleton.  Finally, check to see if
-- the renaming works in the nr and ur terms.

isomorphic :: Gist -> Gist -> Bool
isomorphic g g' =
    nvars g == nvars g' &&
    ntraces g == ntraces g' &&
    norderings g == norderings g' &&
    nnon g == nnon g' &&
    npnon g == npnon g' &&
    nunique g == nunique g' &&
    any (tryPerm g g') (permutations g g')

-- Extend a permutation while extending a substitution
-- Extend by matching later strands first
permutations :: Gist -> Gist -> [((Gen, Env), [Sid])]
permutations g g' =
    map rev $ perms (ggen g', emptyEnv)
                    (reverse $ gtraces g)
                    (reverse $ nats $ ntraces g)
    where
      perms env [] [] = [(env, [])]
      perms env ((h, c):hcs) xs =
          [ (env'', x:ys) |
            x <- xs,
            let (h', c') = gtraces g' !! x,
            h == h',
            env' <- jibeTraces c c' env,
            (env'', ys) <- perms env' hcs (L.delete x xs) ]
      perms _ _ _ = error "Strand.permutations: lists not same length"
      rev (env, xs) = (env, reverse xs)

-- Length of matched traces must agree.
jibeTraces :: Trace -> Trace -> (Gen, Env) -> [(Gen, Env)]
jibeTraces [] [] ge = [ge]
jibeTraces (In t : c) (In t' : c') ge =
    do
      env <- match t t' ge
      jibeTraces c c' env
jibeTraces (Out t : c) (Out t' : c') ge =
    do
      env <- match t t' ge
      jibeTraces c c' env
jibeTraces _ _ _ = []

{-
-- Here is the permutation algorithm used

permutations :: Int -> [[Int]]
permutations n =
    perms (nats n)
    where
      perms []  = [[]]
      perms xs = [ x:ys | x <- xs, ys <- perms (L.delete x xs) ]

-- Here is the usual algorithm

-- Returns a list of all the permutations of the natural numbers less
-- that the argument.  The identity permutation is the first one in
-- the returned list.  The code is based on a function in Haskell 1.3.
permutations :: Int -> [[Int]]
permutations n =
    perms (nats n)
    where
      perms [] = [[]]
      perms (x:xs) = [zs | ys <- perms xs, zs <- interleave x ys]
      interleave x [] = [[x]]
      interleave x (y:ys) = (x:y:ys) : map (y:) (interleave x ys)
-}

tryPerm :: Gist -> Gist -> ((Gen, Env), [Sid]) -> Bool
tryPerm g g' (env, perm) =
    checkOrigs g g' env &&
    containsMapped (permutePair perm) (gorderings g') (gorderings g)

-- containsMapped f xs ys is true when list xs contains each element
-- in ys after being mapped with function f.
containsMapped :: Eq a => (a -> a) -> [a] -> [a] -> Bool
containsMapped f xs ys =
    all (flip elem xs) (map f ys)

permutePair :: [Sid] -> Pair -> Pair
permutePair perm (n, n') = (permuteNode perm n, permuteNode perm n')

permuteNode :: [Sid] -> Node -> Node
permuteNode perm (strand, pos) = (perm !! strand, pos)

checkOrigs :: Gist -> Gist -> (Gen, Env) -> Bool
checkOrigs g g' env =
    not (null
         [ env''' |
           env' <- checkOrig env (gnon g) (gnon g'),
           env'' <- checkOrig env' (gpnon g) (gpnon g'),
           env''' <- checkOrig env'' (gunique g) (gunique g'),
           matchRenaming env''' ])

-- Try all permutations as done above
checkOrig :: (Gen, Env) -> [Term] -> [Term] -> [(Gen, Env)]
checkOrig env [] [] = [env]
checkOrig env (t:ts) ts' =
    do
      t' <- ts'
      env' <- match t t' env
      checkOrig env' ts (L.delete t' ts')
checkOrig _ _ _ = error "Strand.checkOrig: lists not same length"

-- Preskeleton Reduction System (PRS)

-- The PRS reduces a preskeleton to a list of skeletons.  Along the way,
-- it applies the associtated homomorphism to a node and computes a
-- substitution.  Thus if skel (k, n, empty) = [(k', n', sigma)], then
-- phi,sigma is a homomorphism from k to k', n' = phi(n).

type PRS = (Preskel,            -- Parent
            Preskel,            -- Potential cohort member
            Node,               -- Image of test node in member
            [Sid],              -- Strand map part of homomorphism
            Subst)              -- Substition part of homomorphism

-- Extract the protential cohort member from a PRS.
skel :: PRS -> Preskel
skel (_, k, _, _, _) = k

-- Returns the preskeletons that result from applying a substitution.
-- If validate is True, preskeletons that fail to preserve the nodes
-- at which each maybe uniquely originating term originates are filter
-- out.

ksubst :: PRS -> (Gen, Subst) -> [PRS]
ksubst (k0, k, n, phi, hsubst) (gen, subst) =
    do
      (gen', insts') <- foldMapM (substInst subst) gen (insts k)
      let non' = map (substitute subst) (knon k)
      let pnon' = map (substitute subst) (kpnon k)
      let unique' = map (substitute subst) (kunique k)
      let operation' = substOper subst (operation k)
      let k' = newPreskel gen' (shared k) insts'
               (orderings k) non' pnon' unique' (kpriority k)
               operation' (prob k) (pov k)
      k' <- wellFormedPreskel k'
      return (k0, k', n, phi, compose subst hsubst)

-- Monad version of mapAccumR
foldMapM :: Monad m => (a -> b -> m (a, c)) -> a -> [b] -> m (a, [c])
foldMapM _ acc [] = return (acc, [])
foldMapM f acc (x:xs) =
    do
      (acc', xs') <- foldMapM f acc xs
      (acc'', x') <- f acc' x
      return (acc'', x':xs')

substInst :: Subst -> Gen -> Instance -> [(Gen, Instance)]
substInst subst gen i =
    bldInstance (role i) (map (evtMap $ substitute subst) (trace i)) gen

substOper :: Subst -> Operation -> Operation
substOper _ New = New
substOper subst (Contracted s cause) =
    Contracted (compose subst s) (substCause subst cause)
substOper _ m@(Displaced _ _ _ _ _) = m
substOper subst (AddedStrand role height cause) =
    AddedStrand role height (substCause subst cause)
substOper subst (AddedListener t cause) =
    AddedListener (substitute subst t) (substCause subst cause)
substOper _ m@(Generalized _) = m
substOper _ m@(Collapsed _ _) = m

substCause :: Subst -> Cause -> Cause
substCause subst (Cause dir n t escape) =
    Cause dir n (substitute subst t) (S.map (substitute subst) escape)

-- A compression (s is to be eliminated)
compress :: Bool -> PRS -> Sid -> Sid -> [PRS]
compress validate (k0, k, n, phi, hsubst) s s' =
    do
      let perm = updatePerm s s' (strandids k)
      orderings' <- normalizeOrderings validate
                    (permuteOrderings perm (orderings k))
      let k' =
              newPreskel
              (gen k)
              (shared k)
              (deleteNth s (insts k))
              orderings'
              (knon k)
              (kpnon k)
              (kunique k)
              (updatePriority perm (kpriority k))
              (operation k)
              (updateProb perm (prob k))
              (pov k)
      k'' <- wellFormedPreskel k'
      return (k0, k'', permuteNode perm n, map (perm !!) phi, hsubst)

permuteOrderings :: [Sid] -> [Pair] -> [Pair]
permuteOrderings perm orderings = map (permutePair perm) orderings

updatePerm :: Int -> Int -> [Sid] -> [Sid]
updatePerm old new perm =
    map (updateStrand old new) perm

-- Old is to be eliminated and merged into new
updateStrand :: Int -> Int -> Sid -> Sid
updateStrand old new i =
    let j = if old == i then new else i in
    if j > old then j - 1 else j

-- Eliminates implied intrastrand orderings and fails if it finds a
-- reverse intrastrand ordering when flag is true.
normalizeOrderings :: Bool -> [Pair] -> [[Pair]]
normalizeOrderings True orderings =
    loop [] orderings
    where
      loop acc [] = [acc]
      loop acc (p@((s0, i0), (s1, i1)) : ps)
          | s0 /= s1 = loop (p : acc) ps
          | i0 < i1 = loop acc ps
          | otherwise = []
normalizeOrderings False orderings =
    [filter (\ ((s0, _), (s1, _)) -> s0 /= s1) orderings]

updateProb :: [Sid] -> [Sid] -> [Sid]
updateProb mapping prob =
    map (mapping !!) prob

updatePriority :: [Sid] -> [(Node, Int)] -> [(Node, Int)]
updatePriority mapping kpriority =
    map (\(n, i) -> (permuteNode mapping n, i)) kpriority

-- Purge a strand.  Used by thinning.
purge :: PRS -> Sid -> Sid -> [PRS]
purge (k0, k, n, phi, hsubst) s s' =
    do
      let perm = updatePerm s s' (strandids k)
      orderings' <- normalizeOrderings False
                    (permuteOrderings perm
                     (forward s (orderings k)))
      let k' =
              newPreskel
              (gen k)
              (shared k)
              (deleteNth s (insts k))
              orderings'
              (knon k)
              (kpnon k)
              (kunique k)
              (updatePriority perm (kpriority k))
              (operation k)
              (updateProb perm (prob k))
              (pov k)
      k'' <- wellFormedPreskel k'
      return (k0, k'', permuteNode perm n, map (perm !!) phi, hsubst)

-- Forward orderings from strand s
forward :: Sid -> [Pair] -> [Pair]
forward s orderings =
    concatMap f orderings
    where
      f p@((s0, i0), (s1, i1))
          | s0 == s = [((s2, i2), (s1, i1)) | -- Forward here
                       ((s2, i2), (s3, i3)) <- orderings,
                       s3 == s0 && i0 >= i3]
          | s1 == s = []        -- Dump edges to strand s
          | otherwise = [p]     -- Pass thru other edges

-- This is the starting point of the Preskeleton Reduction System
skeletonize :: Bool -> PRS -> [PRS]
skeletonize thin prs
    | hasMultipleOrig prs = []  -- Usual case
    | otherwise = enrich thin prs

hasMultipleOrig :: PRS -> Bool
hasMultipleOrig prs =
    any (\(_, l) -> length l > 1) (korig (skel prs))

-- Hulling or Ensuring Unique Origination
hull :: Bool -> PRS -> [PRS]
hull thin prs =
    loop (korig $ skel prs)
    where
      -- No uniques originate on more than one strand
      loop [] = enrich thin prs
      -- Found a pair that needs hulling
      loop ((_, (s, _) : (s', _) : _) : _) =
        do
          (s'', s''', subst) <- unifyStrands (skel prs) s s'
          prs <- ksubst prs subst
          prs' <- compress False prs s'' s'''
          hull thin prs'
      loop(_ : orig) = loop orig

-- Order Enrichment

-- Adds orderings so that a skeleton respects origination.

enrich :: Bool -> PRS -> [PRS]
enrich thin (k0, k, n, phi, hsubst) =
    let o = foldl (addOrderings k) (orderings k) (kunique k) in
    if length o == length (orderings k) then
        maybeThin thin (k0, k, n, phi, hsubst) -- Nothing to add
    else
        do
          let k' =
                  newPreskel
                  (gen k)
                  (shared k)
                  (insts k)
                  o
                  (knon k)
                  (kpnon k)
                  (kunique k)
                  (kpriority k)
                  (operation k)
                  (prob k)
                  (pov k)
          k' <- wellFormedPreskel k'
          maybeThin thin (k0, k', n, phi, hsubst)

maybeThin :: Bool -> PRS -> [PRS]
maybeThin True prs = thin prs
maybeThin False prs = reduce prs

origNode :: Preskel -> Term -> Maybe Node
origNode k t =
    case lookup t (korig k) of
      Nothing -> error "Strand.origNode: term not in kunique"
      Just [] -> Nothing
      Just [n] -> Just n
      Just _ -> error "Strand.origNode: not a hulled skeleton"

addOrderings :: Preskel -> [Pair] -> Term -> [Pair]
addOrderings k orderings t =
    case origNode k t of
      Nothing -> orderings
      Just n@(s, _) ->
          foldl f orderings (L.delete s (strandids k))
          where
            f orderings s =
                case gainedPos t (trace (strandInst k s)) of
                  Nothing -> orderings
                  Just pos -> adjoin (n, (s, pos)) orderings

matchTraces :: Trace -> Trace -> (Gen, Env) -> [(Gen, Env)]
matchTraces [] _ env = [env]    -- Pattern can be shorter
matchTraces (In t : c) (In t' : c') env =
    do
      e <- match t t' env
      matchTraces c c' e
matchTraces (Out t : c) (Out t' : c') env =
    do
      e <- match t t' env
      matchTraces c c' e
matchTraces _ _ _ = []

-- Make sure a substitution does not take a unique out of the set of
-- uniques, and the same for nons and pnons.
origCheck :: Preskel -> Env -> Bool
origCheck k env =
    check (kunique k) && check (knon k) && check (kpnon k)
    where
      check orig =
          all (pred orig) orig
      pred set item =
          elem (instantiate env item) set

-- Thinning

thin :: PRS -> [PRS]
thin prs =
    thinStrands prs [] $ reverse ss
    where                       -- Remove strands in image of POV
      ss = filter (\s -> notElem s (prob $ skel prs)) (strandids $ skel prs)

-- Takes a skeleton, a list of pairs of strands that matched, and a
-- list of strands yet to be analyzed, and produces the result of
-- skeletonization.  It first tries single pair thinning, and during
-- that process collects potential multistrand thinning pairs.  Once
-- there are no more unanalyzed strands, it tries multistrand
-- thinning.
thinStrands :: PRS -> [(Sid, Sid)] -> [Sid] -> [PRS]
thinStrands prs ps [] =         -- All strands analyzied
    case multiPairs ps of       -- Generate multipairs
      [] -> reduce prs
      mps -> thinMany prs mps   -- Try multistrand thinning
thinStrands prs ps (s:ss) =
  thinStrandPairs prs ps s ss ss

-- This loop tries pairs of strands.  Takes a skeleton, a list of
-- pairs of strands that matched but did not thin, a strand to be
-- eliminated, a list of strands to be used in the outer loop
-- (thinStrands), and a list of strands to be considered for matching,
-- and produces the result of skeletonization.
thinStrandPairs :: PRS -> [(Sid, Sid)] -> Sid -> [Sid] -> [Sid] -> [PRS]
thinStrandPairs prs ps _ ss [] =
  thinStrands prs ps ss
thinStrandPairs prs ps s ss (s':ss') =
  case thinStrand prs s s' of
    -- Try next pair, there was no match
    Nothing -> thinStrandPairs prs ps s ss ss'
    -- Try next pair, there was a match so save this pair
    Just [] -> thinStrandPairs prs ((s, s'):ps) s ss ss'
    Just prss ->                -- Success at single strand thinning
      do
        prs <- prss
        thin prs                -- Restart from the beginning

-- Try thinning s with s'.  If there was no match, return Nothing,
-- else return Just the list of results.
thinStrand :: PRS -> Sid -> Sid -> Maybe [PRS]
thinStrand prs s s' =
    let k = skel prs in
    case thinStrandMatch k s s' (gen k, emptyEnv) of
      [] -> Nothing
      ges ->
          Just $ do
            e <- ges
            (gen, env) <- thinStrandCheck k s e
            [ prs' | prs <- ksubst prs (gen, substitution env),
                     prs <- reduce prs,
                     prs' <- purge prs s s',
                     prs'' <- purge prs s' s,
                     isomorphic (gist (skel prs')) (gist (skel prs''))]

-- See if two strands match.
thinStrandMatch :: Preskel -> Sid -> Sid -> (Gen, Env) -> [(Gen, Env)]
thinStrandMatch k s s' env =
  do
    let i = strandInst k s
    let i' = strandInst k s'
    case height i /= height i' of
      True -> fail ""
      False -> return ()
    matchTraces (trace i) (trace i') env

-- Do the identity, renaming, and origination check.
thinStrandCheck :: Preskel -> Sid -> (Gen, Env) -> [(Gen, Env)]
thinStrandCheck k s env =
  do
    let ts = concatMap (tterms . trace) $ deleteNth s $ insts k
    (gen', env') <- identityEnvFor env ts
    case matchRenaming (gen', env') of
      True -> return ()
      False -> fail ""
    case origCheck k env' of
      True -> return (gen', env')
      False -> fail ""

-- Multistrand thinning

-- Generate all candidate pairings
multiPairs :: [(Sid, Sid)] ->  [[(Sid, Sid)]]
multiPairs _ | useSingleStrandThinning = []
multiPairs ps = filter atLeastTwo $ thinOne ps

-- List is of length at least two.
atLeastTwo :: [a] -> Bool
atLeastTwo (_:_:_) = True
atLeastTwo _ = False

thinOne :: [(Sid, Sid)] -> [[(Sid, Sid)]]
thinOne [] = []
thinOne (p:ps) =
    thinTwo p ps ++ thinOne ps

-- Construct possible pairs that include (s, s').
thinTwo :: (Sid, Sid) -> [(Sid, Sid)] -> [[(Sid, Sid)]]
thinTwo (s, s') ps =
    [(s, s')] : [(s, s') : ps' | ps' <- thinOne (filter (diff (s, s')) ps)]
    where                       -- filter out pairs with seen strands
      diff (s0, s1) (s2, s3) =
          s0 /= s2 && s0 /= s3 && s1 /= s2 && s1 /= s3

-- Try all multistrand pairings until one succeeds.
thinMany :: PRS -> [[(Sid, Sid)]] -> [PRS]
thinMany prs [] = reduce prs
thinMany prs (ps:mps) =
    case thinManyStrands prs ps of
      [] -> thinMany prs mps
      prss ->                           -- Success
        do
          prs <- prss
          thin prs

thinManyStrands :: PRS -> [(Sid, Sid)] -> [PRS]
thinManyStrands prs ps =
    do
      let k = skel prs
      (gen, env) <- thinManyMatch k ps
      [ prs' | prs <- ksubst prs (gen, substitution env),
               prs <- reduce prs,
               prs' <- compressMany prs ps,
               prs'' <- compressMany prs (swap ps),
               isomorphic (gist (skel prs')) (gist (skel prs''))]

thinManyMatch :: Preskel -> [(Sid, Sid)] -> [(Gen, Env)]
thinManyMatch k ps =
    do
      let f e (s, s') = thinStrandMatch k s s' e
      env <- foldM f (gen k, emptyEnv) ps
      let ss = concatMap (\(s, s') -> [s, s']) ps
      let ts = concatMap (tterms . trace) $ deleteMany ss $ insts k
      (gen', env') <- identityEnvFor env ts
      case matchRenaming (gen', env') of
        True -> return ()
        False -> fail ""
      case origCheck k env' of
        True -> return (gen', env')
        False -> fail ""

deleteMany :: [Int] -> [a] -> [a]
deleteMany nums xs =
    loop 0 xs
    where
      loop _ [] = []
      loop n (x:xs) | elem n nums = loop (n + 1) xs
                    | otherwise = x : loop (n + 1) xs

compressMany :: PRS -> [(Sid, Sid)] -> [PRS]
compressMany prs [] = [prs]
compressMany prs ((s, s'):ps) =
    do
      prs' <- purge prs s s'
      compressMany prs' (map (updatePairs s s') ps)

swap :: [(a, a)] -> [(a, a)]
swap ps =
    map (\(x, y) -> (y, x)) ps

updatePairs :: Sid -> Sid -> (Sid, Sid) -> (Sid, Sid)
updatePairs old new (s, s') =
    (updateStrand old new s, updateStrand old new s')

-- Transitive Reduction

-- An edge is essential if its removal eliminates all paths from its
-- source to its destination.  This function removes all non-essential
-- edges from the ordering relation.

reduce :: PRS -> [PRS]
reduce (k0, k, n, phi, hsubst) =
    let o = map graphPair (graphReduce (edges k)) in
    if length o == length (orderings k) then
        return (k0, k, n, phi, hsubst) -- Nothing to take away
    else
        do
          let k' =
                  newPreskel
                  (gen k)
                  (shared k)
                  (insts k)
                  o
                  (knon k)
                  (kpnon k)
                  (kunique k)
                  (kpriority k)
                  (operation k)
                  (prob k)
                  (pov k)
          k'' <- wellFormedPreskel k'
          return (k0, k'', n, phi, hsubst)

-- Answers for cohorts
type Ans = (Preskel, Node, [Sid], Subst)

ans :: PRS -> Ans
ans (_, k, n, phi, subst) = (k, n, phi, subst)

-- Homomorphism Filter

homomorphismFilter :: PRS -> [Ans]
homomorphismFilter prs@(k0, k, _, phi, subst)
    | validateMappingSubst k0 phi subst k = [ans prs]
    | otherwise = []

-- Ensure origination nodes a preserved as required to be a homomorphism
validateMappingSubst :: Preskel -> [Sid] -> Subst -> Preskel -> Bool
validateMappingSubst k phi subst k' =
    useNoOrigPreservation || all check (korig k)
    where
      check (u, ns) =
          case lookup (substitute subst u) (korig k') of
            Nothing -> False
            Just ns' -> all (flip elem ns') (map (permuteNode phi) ns)

-- Returns the skeleton associated with a preskeleton or nothing when
-- there isn't one.  Manufacture a node and a term, and then drop them
-- afterwards.
toSkeleton :: Bool -> Preskel -> [Preskel]
toSkeleton thin k =
    do
      prs <- hull thin (k, k, (0, 0), strandids k, emptySubst)
      (k', _, _, _) <- homomorphismFilter prs
      return k'

-- Contraction

contract :: Preskel -> Node -> Cause -> (Gen, Subst) -> [Ans]
contract k n cause subst =
    do
      prs <- ksubst (k, k { operation = Contracted emptySubst cause },
                     n, strandids k, emptySubst) subst
      prs' <- skeletonize useThinningWhileSolving prs
      homomorphismFilter prs'

-- Regular Augmentation

-- First argument determines if displacement is used.
augment :: Preskel -> Node -> Cause -> Role ->
           (Gen, Subst) -> Instance -> [Ans]
augment k0 n cause role subst inst =
    do
      prs <- augmentAndDisplace k0 n cause role subst inst
      homomorphismFilter prs

-- Apply a substitution, and then augment and displace.  Augmentations
-- add an instance and one ordered pair.  Displacements add an ordered
-- pair and may add nodes.

augmentAndDisplace :: Preskel -> Node -> Cause -> Role ->
                      (Gen, Subst) -> Instance -> [PRS]
augmentAndDisplace k0 n cause role subst inst =
    do
      prs <- substAndAugment k0 n cause role subst inst
      augDisplace prs ++ skeletonize useThinningWhileSolving prs

-- Apply the substitution and apply augmentation operator.
substAndAugment :: Preskel -> Node -> Cause -> Role ->
                   (Gen, Subst) -> Instance -> [PRS]
substAndAugment k n cause role subst inst =
    do
      let operation' = AddedStrand (rname role) (height inst) cause
      prs <- ksubst (k, k { operation = operation' }, n,
                     strandids k, emptySubst) subst
      aug prs inst

-- Apply the augmentation operator by adding an instance and one
-- ordered pair.
aug :: PRS -> Instance -> [PRS]
aug (k0, k, n, phi, hsubst) inst =
    do
      let insts' = (insts k) ++ [inst]
      let pair = ((length (insts k), height inst - 1), n)
      let orderings' = pair : orderings k
      let non' = inheritRnon inst ++ (knon k)
      let pnon' = inheritRpnon inst ++ (kpnon k)
      let unique' = inheritRunique inst ++ (kunique k)
      let k' = newPreskel (gen k) (shared k) insts'
           orderings' non' pnon' unique' (kpriority k)
           (operation k) (prob k) (pov k)
      k' <- wellFormedPreskel k'
      return (k0, k', n, phi, hsubst)

-- Inherit non-originating atoms if the traces is long enough
inheritRnon :: Instance -> [Term]
inheritRnon i =
    inherit i (rnorig (role i))

-- Inherit penenetrator non-originating atoms if the traces is long enough
inheritRpnon :: Instance -> [Term]
inheritRpnon i =
    inherit i (rpnorig (role i))

-- Inherit uniquely originating atoms if the traces is long enough
inheritRunique :: Instance -> [Term]
inheritRunique i =
    inherit i (ruorig (role i))

inherit :: Instance -> [(Term, Int)] -> [Term]
inherit i rorigs =
    map (instantiate (env i) . fst) $ filter f rorigs
    where
      f (_, pos) = pos < height i

-- Add all displacements
augDisplace :: PRS -> [PRS]
augDisplace prs =
    do
      let s = nstrands (skel prs) - 1
      s' <- nats s
      augDisplaceStrands prs s s'

-- Try to displace with strand s'
augDisplaceStrands :: PRS -> Sid -> Sid -> [PRS]
augDisplaceStrands (k0, k, n, phi, hsubst) s s' =
    do
      (s, s', subst) <- unifyStrands k s s'
      let op = addedToDisplaced (operation k) s s'
      prs <- ksubst (k0, k { operation = op}, n, phi, hsubst) subst
      prs <- compress True prs s s'
      skeletonize useThinningWhileSolving prs

-- See if two strands unify.  They can be of differing heights.  The
-- second strand returned may be longer.
unifyStrands :: Preskel -> Sid -> Sid -> [(Sid, Sid, (Gen, Subst))]
unifyStrands k s s' =
    let i = strandInst k s
        i' = strandInst k s' in
    if height i > height i' then
        unifyStrands k s' s
    else
        do
          (gen', subst) <- unifyTraces (trace i) (trace i') (gen k, emptySubst)
          return (s, s', (gen', subst))

-- Unify traces where the first trace is allowed to be shorter than
-- the second trace.
unifyTraces :: Trace -> Trace -> (Gen, Subst) -> [(Gen, Subst)]
unifyTraces [] _ subst = [subst]
unifyTraces (In t : c) (In t' : c') subst =
    do
      s <- unify t t' subst
      unifyTraces c c' s
unifyTraces (Out t : c) (Out t' : c') subst =
    do
      s <- unify t t' subst
      unifyTraces c c' s
unifyTraces _ _ _ = []

addedToDisplaced :: Operation -> Int -> Int -> Operation
addedToDisplaced (AddedStrand role height cause) s s' =
    Displaced s s' role height cause
addedToDisplaced _ _ _ = error "Strand.addedToDisplaced: Bad operation"

-- Listener Augmentation

addListener :: Preskel -> Node -> Cause -> Term -> [Ans]
addListener k n cause t =
    do
      k' <- wellFormedPreskel k'
      prs <- skeletonize useThinningWhileSolving
             (k, k', n, strandids k, emptySubst)
      homomorphismFilter prs
    where
      k' = newPreskel gen' (shared k) insts' orderings' (knon k)
           (kpnon k) (kunique k) (kpriority k)
           (AddedListener t cause) (prob k) (pov k)
      (gen', inst) = mkListener (protocol k) (gen k) t
      insts' = insts k ++ [inst]
      pair = ((length (insts k), 1), n)
      orderings' = pair : orderings k

-- Homomorphisms

-- Find a substitution that demonstrates the existence of a
-- homomorphism between the two skeletons using the given
-- strand mapping function.

homomorphism :: Preskel -> Preskel -> [Sid] -> [Env]
homomorphism k k' mapping =
    do
      (_, env) <- findReplacement k k' mapping
      case validateEnv k k' mapping env of
        True -> [env]
        False -> []

findReplacement :: Preskel -> Preskel -> [Sid] -> [(Gen, Env)]
findReplacement k k' mapping =
    foldM (matchStrand k k' mapping) (gen k', emptyEnv) (strandids k)

matchStrand :: Preskel -> Preskel -> [Sid] -> (Gen, Env) -> Sid -> [(Gen, Env)]
matchStrand k k' mapping env s =
    matchTraces (trace (strandInst k s)) (trace (strandInst k' s')) env
    where
      s' = mapping !! s

validateEnv :: Preskel -> Preskel -> [Sid] -> Env -> Bool
validateEnv k k' mapping env =
    all (flip elem (knon k')) (map (instantiate env) (knon k)) &&
    all (flip elem (kpnon k')) (map (instantiate env) (kpnon k)) &&
    all (flip elem (kunique k')) (map (instantiate env) (kunique k)) &&
    validateEnvOrig k k' mapping env &&
    all (flip elem (tc k')) (permuteOrderings mapping (orderings k))

validateEnvOrig :: Preskel -> Preskel -> [Sid] -> Env -> Bool
validateEnvOrig k k' mapping env =
    useNoOrigPreservation || all check (korig k)
    where
      check (u, ns) =
          case lookup (instantiate env u) (korig k') of
            Nothing -> error "Strand.validateEnv: term not in kunique"
            Just ns' -> all (flip elem ns') (map (permuteNode mapping) ns)

-- Given a realized skeleton k, generate candidates for minimization.
-- A candidate is a preskeleton and a strand mapping from the
-- candidate to k.  The preskeleton need not be well formed, as that
-- test is applied elsewhere.

type Candidate = (Preskel, [Sid])

addIdentity :: Preskel -> Candidate
addIdentity k = (k, strandids k)

separateVariablesLimit :: Int
separateVariablesLimit = 1024

generalize :: Preskel -> [Candidate]
generalize k = deleteNodes k ++
               weakenOrderings k ++
               forgetAssumption k ++
               take separateVariablesLimit (separateVariables k)

-- Node deletion

{-

delete node n in k

1. if (s, 0) part of prob return Nothing
2. if not initial node, truncate instance of node else delete instance
3. weaken ordering when filtering it (see shortenOrdering)
4. drop nons that aren't mentioned anywhere
5. drop uniques that aren't carried anywhere
6. update prob upon instance deletion
-}

deleteNodes :: Preskel -> [Candidate]
deleteNodes k =
    do
      strand <- strands k
      node <- nodes strand
      deleteNode k node

deleteNode :: Preskel -> Vertex -> [(Preskel, [Sid])]
deleteNode k n
    | p == 0 && elem s (prob k) = []
    | p == 0 =
        do
          let mapping = deleteNth s (strandids k)
          let k' = deleteNodeRest k (gen k) (s, p) (deleteNth s (insts k))
                   (deleteOrderings s (tc k)) (updatePerm s s (prob k))
          return (k', mapping)
    | otherwise =
        do
          let mapping = strandids k
          let i = inst (strand n)
          (gen', i') <- bldInstance (role i) (take p (trace i)) (gen k)
          let k' = deleteNodeRest k gen' (s, p) (replaceNth i' s (insts k))
                   (shortenOrderings (s, p) (tc k)) (prob k)
          return (k', mapping)
    where
      p = pos n
      s = sid (strand n)

-- Update orderings when a strand is eliminated (p == 0)
deleteOrderings :: Sid -> [Pair] -> [Pair]
deleteOrderings s ps =
    do
      p <- ps
      deleteOrdering p
    where
      deleteOrdering (n0@(s0, _), n1@(s1, _))
          | s == s0 || s == s1 = []
          | otherwise = [(adjust n0, adjust n1)]
      adjust n@(s', i')
          | s' > s = (s' - 1, i')
          | otherwise = n

-- Update orderings when a strand is shortened (p > 0)
shortenOrderings :: Node -> [Pair] -> [Pair]
shortenOrderings (s, i) ps =
    do
      pair <- ps
      shortenOrdering pair
    where
      shortenOrdering p@((s0, i0), (s1, i1))
          | s == s0 && i <= i0 = []
          | s == s1 && i <= i1 = []
          | otherwise = [p]

deleteNodeRest :: Preskel -> Gen -> Node -> [Instance] -> [Pair] ->
                  [Sid] -> Preskel
deleteNodeRest k gen n insts' orderings prob =
    newPreskel gen (shared k) insts' orderings non' pnon' unique'
                   prio' (Generalized (Deleted n)) prob (pov k)
    where
      -- Drop nons that aren't mentioned anywhere
      non' = filter mentionedIn (knon k)
      pnon' = filter mentionedIn (kpnon k)
      mentionedIn t = varSubset [t] terms
      terms = iterms insts'
      -- Drop uniques that aren't carried anywhere
      unique' = filter carriedIn (kunique k)
      carriedIn t = any (carriedBy t) terms
      -- Drop unused priorities
      prio' = filter within (kpriority k)
      within ((s, i), _) =
        s < fst n || s == fst n && i < snd n

-- Node ordering weakening

-- To weaken, create a candidate for each element in the current
-- ordering, which is already the result of a transitive reduction.
-- Weaken by computing the transitive closure of the ordering, and
-- then remove the selected element from the current ordering.  After
-- computing the transitive closure, filter out the edges that are not
-- well ordered, i.e. originate at a reception node or terminate at a
-- transmission node.  Also, filter out edges that link nodes in the
-- same strand.  The preskeleton constructor function performs a
-- transitive reduction on the generated ordering.

weakenOrderings :: Preskel -> [Candidate]
weakenOrderings k =
    map (weakenOrdering k) (orderings k)

weakenOrdering :: Preskel -> Pair -> Candidate
weakenOrdering k p =
    weaken k p (L.delete p (tc k))

weaken :: Preskel -> Pair -> [Pair] -> Candidate
weaken k p orderings =
    addIdentity k'
    where
      k' = newPreskel (gen k) (shared k) (insts k)
           orderings (knon k) (kpnon k) (kunique k) (kpriority k)
           (Generalized (Weakened p)) (prob k) (pov k)

-- Origination assumption forgetting

-- Delete each non-originating term that is not specified by a
-- role.  Do the same for each uniquely-originating term.

forgetAssumption :: Preskel -> [Candidate]
forgetAssumption k =
    forgetNonTerm k ++ forgetPnonTerm k ++ forgetUniqueTerm k

-- Non-originating terms

forgetNonTerm :: Preskel -> [Candidate]
forgetNonTerm k =
    map (addIdentity . delNon) (skelNons k)
    where
      delNon t =
          k { knon = L.delete t (knon k),
              operation = Generalized (Forgot t) }

skelNons :: Preskel -> [Term]
skelNons k =
    filter (flip notElem ru) (knon k)
    where
      ru = [u | i <- insts k, u <- inheritRnon i]

-- Penetrator non-originating terms

forgetPnonTerm :: Preskel -> [Candidate]
forgetPnonTerm k =
    map (addIdentity . delPnon) (skelPnons k)
    where
      delPnon t =
          k { kpnon = L.delete t (kpnon k),
              operation = Generalized (Forgot t) }

skelPnons :: Preskel -> [Term]
skelPnons k =
    filter (flip notElem ru) (kpnon k)
    where
      ru = [u | i <- insts k, u <- inheritRpnon i]

-- Uniquely-originating terms

forgetUniqueTerm :: Preskel -> [Candidate]
forgetUniqueTerm k =
    map (addIdentity . delUniq) (skelUniques k)
    where
      delUniq t =
          k { kunique = L.delete t (kunique k),
              operation = Generalized (Forgot t) }

skelUniques :: Preskel -> [Term]
skelUniques k =
    filter (flip notElem ru) (kunique k)
    where
      ru = [u | i <- insts k, u <- inheritRunique i]

-- Variable separation

-- A location is a strand, a role variable, and a position in the term
-- associated with the role variable.

-- step one: extract places
--
-- for each maplet in each environment in each strand
--   for each variable V in the range of the maplet
--     let P be the places at which V occurs
--     associate V with the location described by each element in P
--
-- step two: generate preskeletons
--
-- for each variable V in the skeleton K
--  let V' be a clone of V
--  let L be the set of locations associated with V from above
--  for each subset L' of L
--    for each instance I in K
--      update the environment of I by replacing V' at the locations
--      given by L' that refer to I, and use the modified environment
--      to update the instance
--    let K' be the result of updating instances in K as above
--    if V occurs in non, add terms with V replaced by V' to
--      the non's of K'
--    if V occurs in unique, add terms with V replaced by V'
--      to the unique's of K'
--    add K' to the list of generated preskeletons

separateVariables :: Preskel -> [Candidate]
separateVariables k =
    do
      v <- kvars k
      separateVariable k (extractPlaces k) v

-- A location is a strand, a role variable, and a position in the term
-- associated with the role variable.

type Location = (Sid, Term, Place)

-- Returns a list of pairs.  For each occurrence of a preskeleton
-- variable in every instance, there is a pair where the first element
-- is the variable, and the second as the location at which it occurs.
extractPlaces :: Preskel ->
                 [(Term, Location)]
extractPlaces k =
    [ (var, (sid s, v, p)) |
      s <- strands k,
      (v, t) <- instAssocs (inst s),
      var <- foldVars (flip adjoin) [] t,
      p <- places var t ]

instAssocs :: Instance -> [(Term, Term)]
instAssocs i =
    reify (rvars (role i)) (env i)

-- For each variable, generate candidates by generating a fresh
-- variable for subsets of the locations associated with the variable.
separateVariable :: Preskel -> [(Term, Location)] -> Term -> [Candidate]
separateVariable k ps t =
    sepVar (locsFor ps t)
    where
      sepVar [] = []
      sepVar [_] = []
      sepVar locs =
          do
            locs' <- parts locs
            changeLocations k env gen'' t' locs'
      (gen'', env) = matchAlways t t' (gen', emptyEnv)
      parts locs = map (map (locs !!)) (subsets (length locs))
      (gen', t') = clone (gen k) t

-- Extract the locations for a given variable
locsFor :: [(Term, Location)] -> Term -> [Location]
locsFor ps t =
    map snd (filter (\(t', _) -> t == t') (reverse ps)) -- Why reverse?

matchAlways :: Term -> Term -> (Gen, Env) -> (Gen, Env)
matchAlways t t' env =
    case match t t' env of
      e : _ -> e
      [] -> error "Strand.matchAlways: bad match"

-- Change the given locations and create the resulting preskeleton
changeLocations :: Preskel -> Env -> Gen -> Term -> [Location] -> [Candidate]
changeLocations k env gen t locs =
    [addIdentity k0, addIdentity k1]
    where
      k0 = newPreskel gen' (shared k) insts' (orderings k) non pnon unique0
           (kpriority k) (Generalized (Separated t)) (prob k) (pov k)
      k1 = newPreskel gen' (shared k) insts' (orderings k) non pnon unique1
           (kpriority k) (Generalized (Separated t)) (prob k) (pov k)
      (gen', insts') = changeStrands locs t gen (strands k)
      non = knon k ++ map (instantiate env) (knon k)
      pnon = kpnon k ++ map (instantiate env) (kpnon k)
      unique0 = kunique k ++ unique'
      unique1 = map (instantiate env) (kunique k) ++ unique'
      -- Ensure all role unique assumptions are in.
      unique' = concatMap inheritRunique insts'

changeStrands :: [Location] -> Term -> Gen -> [Strand] -> (Gen, [Instance])
changeStrands locs copy gen strands =
    case foldMapM (changeStrand locs copy) gen strands of
      i : _ -> i
      [] -> error "Strand.changeStrands: bad strand build"

-- Create an new environment incorporating changes, and from that,
-- create the new strand.
changeStrand :: [Location] -> Term -> Gen -> Strand -> [(Gen, Instance)]
changeStrand locs copy gen s =
    bldInstance (role i) trace'  gen'
    where
      i = inst s
      (gen', env') = foldl f (gen, emptyEnv)
             (map (changeMaplet locs copy (sid s)) (instAssocs i))
      f env (v, t) = matchAlways v t env
      trace' = map (evtMap $ instantiate env') trace
      trace = take (height i) (rtrace (role i))

-- Change a maplet
changeMaplet :: [Location] -> Term -> Sid -> (Term, Term) -> (Term, Term)
changeMaplet [] _ _ maplet = maplet
changeMaplet ((s', v', p) : locs) copy s (v, t) =
    changeMaplet locs copy s (v, t')
    where
      t' = if s' == s && v' == v then replace copy p t else t

-- Return the set of subsets of natural numbers less than n
subsets :: Int -> [[Int]]
subsets n
    | n < 0 = error $ "Utilities.subsets: Bad argument " ++ show n
    | n == 0 = []
    | otherwise =
        [n - 1] : subset ++ map (n - 1 :) subset
        where
          subset = subsets (n - 1)

-- Collapse a shape by unifying strands.

collapse :: Preskel -> [Preskel]
collapse k =
    [k' | s <- strandids k, s' <- nats s,
          k' <- collapseStrands k s s']

collapseStrands :: Preskel -> Sid -> Sid -> [Preskel]
collapseStrands k s s' =
    do
      (s, s', subst) <- unifyStrands k s s'
      prs <- ksubst (k, k { operation = Collapsed s s' },
                     (0, 0), strandids k, emptySubst) subst
      prs <- compress True prs s s'
      prs <- skeletonize useThinningDuringCollapsing prs
      return $ skel prs

-- Security goals: satisfaction of atomic formulas

type Sem = Preskel -> (Gen, Env) -> [(Gen, Env)]

-- Extends an environment (a variable assignment) according to the
-- given atomic formula.
satisfy :: AForm -> Sem
satisfy (Equals t t') = geq t t'
satisfy (Non t) = ggnon t
satisfy (Pnon t) = ggpnon t
satisfy (Uniq t) = gguniq t
satisfy (UniqAt t n) = guniqAt t n
satisfy (StrPrec n n') = gstrPrec n n'
satisfy (Prec n n') = gprec n n'
satisfy (RolePred r i n) = grole r i n
satisfy (ParamPred r v n t) = gparam r v n t

-- Equality assumes there has been a static role specific check to
-- eliminate error cases.
geq :: Term -> Term -> Sem
geq t t' _ (g, e)
  | ti == ti' = [(g, e)]
  | otherwise = []
  where
    ti = instantiate e t
    ti' = instantiate e t'

-- Non-origination
ggnon :: Term -> Sem
ggnon t k e =
  do
    t' <- knon k
    match t t' e

-- Penetrator non-origination
ggpnon :: Term -> Sem
ggpnon t k e =
  do
    t' <- kpnon k
    match t t' e

-- Unique origination
gguniq :: Term -> Sem
gguniq t k e =
  do
    t' <- kunique k
    match t t' e

-- Unique origination at a node
guniqAt :: Term -> Term -> Sem
guniqAt t n k e =
  do
    (t', ls) <- korig k
    case ls of
      [l] ->
        do
          e <- match t t' e
          nodeMatch n l e
      _ -> []

inSkel :: Preskel -> (Int, Int) -> Bool
inSkel k (s, i) =
  s >= 0 && s < nstrands k && i >= 0 && i < height (insts k !! s)

strandPrec :: Node -> Node -> Bool
strandPrec (s, i) (s', i')
  | s == s' && i < i' = True
  | otherwise = False

-- Within strand node precedes
gstrPrec :: Term -> Term -> Sem
gstrPrec n n' k (g, e) =
  case (nodeLookup e n, nodeLookup e n') of
    (Just p, Just p')
      | inSkel k p && inSkel k p' && strandPrec p p' -> [(g, e)]
    (Just _, Just _) -> []
    (_, Just _) ->
      error ("Strand.gstrPrec: node " ++ show n ++ " unbound")
    _ ->
      error ("Strand.gstrPrec: node " ++ show n' ++ " unbound")

-- Node precedes
-- This should look at the transitive closure of the ordering graph.
gprec :: Term -> Term -> Sem
gprec n n' k (g, e) =
  case (nodeLookup e n, nodeLookup e n') of
    (Just p, Just p')
      | inSkel k p && inSkel k p' &&
        (strandPrec p p' || elem (p, p') tc) -> [(g, e)]
    (Just _, Just _) -> []
    (_, Just _) ->
      error ("Strand.gstrPrec: node " ++ show n ++ " unbound")
    _ ->
      error ("Strand.gstrPrec: node " ++ show n' ++ " unbound")
  where
    tc = map graphPair $ graphClose $ graphEdges $ strands k

-- Role predicate
-- r and i determine the predicate, which has arity one.
grole :: Role -> Int -> Term -> Sem
grole r i n k (g, e) =
  case nodeLookup e n of
    Nothing ->
      do
        (z, inst) <- zip [0..] $ insts k
        case () of
          _ | i >= height inst -> []
            | rname (role inst) == rname r -> nodeMatch n (z, i) (g, e)
            | otherwise ->      -- See if z could have been an instance of r
              case bldInstance r (take (i + 1) $ trace inst) g of
                [] -> []
                _ -> nodeMatch n (z, i) (g, e)
    Just (z, j) | z < nstrands k && i == j ->
      let inst = insts k !! z in
      case () of
        _ | i >= height inst -> []
          | rname (role inst) == rname r -> [(g, e)]
          | otherwise ->
            case bldInstance r (take (i + 1) $ trace inst) g of
              [] -> []
              _ -> [(g, e)]
    _ -> []

-- Parameter predicate

-- r and t determine the predicate, which has arity two.  t must be
-- a variable declared in role r.
gparam :: Role -> Term -> Term -> Term -> Sem
gparam r t n t' k (g, e) =
  case nodeLookup e n of
    Just (z, i) | z < nstrands k  ->
      let inst = insts k !! z in
      case () of
        _ | i >= height inst -> []
          | rname (role inst) == rname r ->
            match t' (instantiate (env inst) t) (g, e)
          | otherwise ->
              do
                (g, inst) <- bldInstance r (take (i + 1) $ trace inst) g
                match t' (instantiate (env inst) t) (g, e)
    Nothing -> error ("Strand.gparam: node " ++ show n ++ " unbound")
    _ -> []

-- Conjunction

conjoin :: [AForm] -> Sem
conjoin [] _ e = [e]
conjoin (a: as) k e =
  do
    e <- satisfy a k e
    conjoin as k e

-- Satisfaction

-- Returns the environments that show satifaction of the antecedent
-- but fail to be extendable to show satifaction of one of the
-- conclusions.
goalSat :: Preskel -> Goal -> (Goal, [Env])
goalSat k g =
  (g, [ e |
        (gen, e) <- conjoin (antec g) k (gen k, emptyEnv),
        conclusion (gen, e) ])
  where
    conclusion e = all (disjunct e) $ concl g
    disjunct e a = null $ conjoin a k e

sat :: Preskel -> [(Goal, [Env])]
sat k =
  map (goalSat k) (kgoals k)