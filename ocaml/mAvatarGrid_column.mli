(* © 2012 RunOrg *)

type column = {
  eval  : MAvatarGrid_eval.t ;
  label : [ `label of string | `text of string ] ;
  show  : bool ;
  view  : MGroupColumn.View.t
}

include Ohm.Fmt.FMT with type t = column

val apply_diffs :
     column list
  -> IGroup.t
  -> IInstance.t
  -> MPreConfigNamer.t
  -> MGroupColumn.Diff.t list
  -> column list O.run
