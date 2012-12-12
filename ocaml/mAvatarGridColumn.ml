(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module T = struct
  type json t = {
    eval  : MAvatarGridEval.t ;
    label : TextOrAdlib.t ;
    view  : MAvatarGridView.t
  }
end

include T 
include Ohm.Fmt.Extend(T)

type column = t = {
  eval  : MAvatarGridEval.t ;
  label : TextOrAdlib.t ; 
  view  : MAvatarGridView.t
}



