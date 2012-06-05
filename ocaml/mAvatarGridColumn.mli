(* © 2012 RunOrg *)

type column = {
  eval  : MAvatarGridEval.t ;
  label : TextOrAdlib.t ;
  show  : bool ;
  view  : MAvatarGridView.t
}

include Ohm.Fmt.FMT with type t = column

