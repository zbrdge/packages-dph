-----------------------------------------------------------------------------
-- |
-- Module      : Data.Array.Parallel.Unlifted.Segmented.SUArr
-- Copyright   : (c) [2001..2002] Manuel M T Chakravarty & Gabriele Keller
--		 (c) 2006         Manuel M T Chakravarty & Roman Leshchinskiy
-- License     : see libraries/base/LICENSE
-- 
-- Maintainer  : Manuel M T Chakravarty <chak@cse.unsw.edu.au>
-- Stability   : internal
-- Portability : portable
--
-- Description ---------------------------------------------------------------
--
-- This module defines segmented arrays in terms of unsegmented ones.
--
-- Todo ----------------------------------------------------------------------
--

module Data.Array.Parallel.Unlifted.Segmented.SUArr (

  -- * Array types and classes containing the admissble elements types
  USegd(..), MUSegd(..), SUArr(..), MSUArr(..),

  -- * Basic operations on segmented parallel arrays
  lengthSU, indexSU, sliceIndexSU, extractIndexSU, sliceSU, extractSU,
  flattenSU, (>:), newMSU, nextMSU, unsafeFreezeMSU, toUSegd, fromUSegd

) where

-- friends
import Data.Array.Parallel.Base ((:*:)(..), ST)
import Data.Array.Parallel.Unlifted.Flat (
  UA, UArr, MUArr,
  lengthU, (!:), sliceU, extractU, mapU, scanU,
  newMU, readMU, writeMU, unsafeFreezeMU)

infixl 9 `indexSU`
infixr 9 >:


-- |Segmented arrays
-- -----------------

-- |Segment descriptors are used to represent the structure of nested arrays.
--
data USegd = USegd {
	       segdUS :: !(UArr Int),  -- segment lengths
	       psumUS :: !(UArr Int)   -- prefix sum of former
	     }

-- |Mutable segment descriptor
--
data MUSegd s = MUSegd {
	          segdMUS :: !(MUArr Int s),  -- segment lengths
	          psumMUS :: !(MUArr Int s)   -- prefix sum of former
	        }

-- |Segmented arrays (only one level of segmentation)
-- 
data SUArr e = SUArr {
                 segdSU :: !USegd,             -- segment descriptor
                 dataSU :: !(UArr e)           -- flat data array
               }

-- |Mutable segmented arrays (only one level of segmentation)
--
data MSUArr e s = MSUArr {
                    segdMSU :: !(MUSegd s),    -- segment descriptor
                    dataMSU :: !(MUArr e s)    -- flat data array
                  }

-- |Operations on segmented arrays
-- -------------------------------

-- |Yield the number of segments.
-- 
lengthSU :: UA e => SUArr e -> Int
lengthSU (SUArr segd _) = lengthU (segdUS segd)

-- |Extract the segment at the given index using the given extraction function
-- (either 'sliceU' or 'extractU').
-- 
indexSU :: UA e => (UArr e -> Int -> Int -> UArr e) -> SUArr e -> Int -> UArr e
indexSU copy (SUArr segd a) i = copy a (psumUS segd !: i)
                                       (segdUS segd !: i)

-- |Extract the segment at the given index without copying the elements.
--
sliceIndexSU :: UA e => SUArr e -> Int -> UArr e
sliceIndexSU = indexSU sliceU

-- |Extract the segment at the given index (elements are copied).
-- 
extractIndexSU :: UA e => SUArr e -> Int -> UArr e
extractIndexSU = indexSU extractU

-- |Extract a subrange of the segmented array without copying the elements.
--
sliceSU :: UA e => SUArr e -> Int -> Int -> SUArr e
sliceSU (SUArr segd a) i n =
  let
    segd1 = segdUS segd
    psum  = psumUS segd
    m     = if i == 0 then 0 else psum !: (i - 1)
    psum' = mapU (subtract m) (sliceU psum i n)
    segd' = USegd (sliceU segd1 i n) psum'
    i'    = psum !: i
  in
  SUArr segd' (sliceU a i' (psum !: (i + n - 1) - i' + 1))

-- |Extract a subrange of the segmented array (elements are copied).
--
extractSU :: UA e => SUArr e -> Int -> Int -> SUArr e
extractSU (SUArr segd a) i n =
  let
    segd1 = segdUS segd
    psum  = psumUS segd
    m     = if i == 0 then 0 else psum !: (i - 1)
    psum' = mapU (subtract m) (extractU psum i n)
    segd' = USegd (extractU segd1 i n) psum'
    i'    = psum !: i
  in
  SUArr segd' (extractU a i' (psum !: (i + n - 1) - i' + 1))

-- |The functions `newMSU', `nextMSU', and `unsafeFreezeMSU' are to 
-- iteratively define a segmented mutable array; i.e., arrays of type `MSUArr
-- s e`.

-- |Allocate a segmented parallel array (providing the number of segments and
-- number of base elements).
--
newMSU :: UA e => Int -> Int -> ST s (MSUArr e s)
{-# INLINE newMSU #-}
newMSU nsegd n = do
		   segd <- newMU nsegd
		   psum <- newMU nsegd
		   a    <- newMU n
		   return $ MSUArr (MUSegd segd psum) a

-- |Iterator support for filling a segmented mutable array left-to-right.
--
-- * If no element is given (ie, third argument is `Nothing'), a segment is
--   initialised.  Segment initialisation relies on previous segments already
--   being completed.
--
-- * Every segment must be initialised before it is filled left-to-right
--
nextMSU :: UA e => MSUArr e s -> Int -> Maybe e -> ST s ()
{-# INLINE nextMSU #-}
nextMSU (MSUArr (MUSegd segd psum) a) i Nothing =
  do                                                -- segment initialisation
    i' <- if i == 0 then return 0 
		    else do
		      off <- psum `readMU` (i - 1)
		      n   <- segd `readMU` (i - 1)
		      return $ off + n
    writeMU psum i i'
    writeMU segd i 0
nextMSU (MSUArr (MUSegd segd psum) a) i (Just e) = 
  do
    i' <- psum `readMU` i
    n' <- segd `readMU` i
    writeMU a (i' + n') e
    writeMU segd i (n' + 1)

-- |Convert a mutable segmented array into an immutable one.
--
unsafeFreezeMSU :: UA e => MSUArr e s -> Int -> ST s (SUArr e)
{-# INLINE unsafeFreezeMSU #-}
unsafeFreezeMSU (MSUArr segd a) n = 
  do
    segd' <- unsafeFreezeMU (segdMUS segd) n
    psum' <- unsafeFreezeMU (psumMUS segd) n
    let n' = if n == 0 then 0 else psum' !: (n - 1) + 
				   segd' !: (n - 1)
    a' <- unsafeFreezeMU a n'
    return $ SUArr (USegd segd' psum') a'


-- |Basic operations on segmented arrays
-- -------------------------------------

-- |Compose a nested array.
--
(>:) :: UA a => USegd -> UArr a -> SUArr a
{-# INLINE [1] (>:) #-}  -- see `UAFusion'
(>:) = SUArr

-- |Decompose a nested array.
--
flattenSU :: UA a => SUArr a -> (USegd :*: UArr a)
flattenSU (SUArr segd a) = (segd :*: a)

-- |Convert a length array into a segment descriptor.
--
toUSegd :: UArr Int -> USegd 
toUSegd lens = USegd lens (scanU (+) 0 lens)

-- |Extract the length array from a segment descriptor.
--
fromUSegd :: USegd -> UArr Int
fromUSegd (USegd lens _) = lens
