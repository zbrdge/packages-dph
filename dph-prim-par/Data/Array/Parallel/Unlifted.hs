{-# LANGUAGE CPP #-}

#include "DPH_Header.h"

import Data.Array.Parallel.Unlifted.Parallel
import Data.Array.Parallel.Unlifted.Distributed ( DT )
import Data.Array.Parallel.Unlifted.Sequential
  hiding ((!:), (+:+))
import qualified Data.Array.Parallel.Unlifted.Sequential
  as U

#include "DPH_Interface.h"

class (UA a, DT a) => Elt a
type Array = UArr
type Segd = UPSegd
type Sel2 = UPSel2
type SelRep2 = UPSelRep2

length = lengthU
empty = emptyU
replicate = replicateUP
repeat n _ = repeatUP n
(!:) = (U.!:)
extract = extractU
drop = dropUP
permute = permuteU
bpermuteDft = bpermuteDftU
bpermute = bpermuteUP
mbpermute = mbpermuteU
update = updateUP
(+:+) = (U.+:+)
interleave = interleaveUP
pack = packUP
combine = combineUP
combine2 = combine2UP
map = mapUP
filter = filterUP
zip = zipU
unzip = unzipU
fsts = fstU
snds = sndU
zipWith = zipWithUP
fold = foldUP
fold1 = fold1U
and = andUP
sum = sumUP
scan = scanUP
indexed = indexedUP
enumFromTo = enumFromToUP
enumFromThenTo = enumFromThenToUP
enumFromStepLen = enumFromStepLenUP
enumFromStepLenEach =enumFromStepLenEachUP

mkSel2 = mkUPSel2
tagsSel2 = tagsUPSel2
indicesSel2 = indicesUPSel2
elementsSel2_0 = elementsUPSel2_0
elementsSel2_1 = elementsUPSel2_1
repSel2 = repUPSel2

mkSelRep2 = mkUPSelRep2
indicesSelRep2 = indicesUPSelRep2
elementsSelRep2_0 = elementsUPSelRep2_0
elementsSelRep2_1 = elementsUPSelRep2_1

replicate_s = replicateSUP
replicate_rs = replicateRSUP
append_s = appendSUP
fold_s = foldSUP
fold1_s = fold1SUP
fold_r = foldlRU
sum_r = sumRUP

indices_s segd = indicesSUP segd

lengthSegd = lengthUPSegd
lengthsSegd = lengthsUPSegd
indicesSegd = indicesUPSegd
elementsSegd = elementsUPSegd
mkSegd = mkUPSegd
randoms = randomU
randomRs = randomRU
class UIO a => IOElt a
hPut = hPutU
hGet = hGetU
toList = fromU
fromList = toU

