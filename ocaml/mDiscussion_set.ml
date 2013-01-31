(* © 2012 RunOrg *)
  
open Ohm
open Ohm.Universal
open BatPervasives
  
module Core = MDiscussion_core
module Can  = MDiscussion_can

include HEntity.Set(Can)(Core)

let edit ~title ~body t self = 
  let e = Can.data t in 
  let diffs = BatList.filter_map identity [
    (if title = e.Core.title then None else Some (`SetTitle title)) ;
    (if body  = e.Core.body  then None else Some (`SetBody body)) ;
  ] in
  if diffs = [] then return () else update diffs t self 

