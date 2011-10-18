module Data.Array.Parallel.Prelude.Tuple (
  tup2, tup3
) where
  
import Data.Array.Parallel.Lifted.Closure
import Data.Array.Parallel.PArray.PData.Tuple
import Data.Array.Parallel.PArray.PRepr


tup2 :: (PA a, PA b) => a :-> b :-> (a, b)
{-# INLINE tup2 #-}
tup2 = closure2 (,) (error "tup2") -- zipPA#

tup3 :: (PA a, PA b, PA c) => a :-> b :-> c :-> (a, b, c)
{-# INLINE tup3 #-}
tup3 = closure3 (,,) (error "tup3") -- zip3PA#