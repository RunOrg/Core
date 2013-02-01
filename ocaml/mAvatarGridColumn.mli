(* © 2013 RunOrg *)

type column = {
  eval  : MAvatarGridEval.t ;
  label : TextOrAdlib.t ;
  view  : MAvatarGridView.t
}

include Ohm.Fmt.FMT with type t = column

