module Bidule

open FStar.DM4F.Heap
open FStar.DM4F.Heap.ST

reifiable let x () : STNull unit = ()

let chose (h0 : heap) (r:(ref int){h0 `contains_a_well_typed` r}) =
  let h1 = normalize_term (snd (reify (write r 42) h0)) in
  assert (h1 == upd h0 r 42)
