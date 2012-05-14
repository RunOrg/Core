(* © 2012 MRunOrg *)

val name_suggestions : (string * (string list)) list O.run

type ('id,'payload) version = <
  applies : 'id list ;
  version : string ;
  payload : 'payload list
>

module TemplateDiff : Ohm.JoyA.FMT with type t = 
  [ `Config of MEntityConfig.Diff.t 
  | `Info   of MEntityInfo.Diff.t 
  | `Field  of MEntityFields.Diff.t 
  | `Column of MGroupColumn.Diff.t 
  | `Join   of MJoinFields.Diff.t
  | `Propagate of MGroupPropagate.Entity.Diff.t ]

module VerticalDiff : Ohm.JoyA.FMT with type t = 
  [ `Entities of MInstanceEntity.Diff.t 
  | `Propagate of MGroupPropagate.Diff.t ]

val print_template_version : (ITemplate.t,TemplateDiff.t) version -> string
val print_vertical_version : (IVertical.t,VerticalDiff.t) version -> string

class type entity_diffs = object
  method config  : MEntityConfig.Diff.t list 
  method   info  : MEntityInfo.Diff.t list 
  method fields  : MEntityFields.Diff.t list 
  method columns : MGroupColumn.Diff.t list 
  method join    : MJoinFields.Diff.t list
  method propagate : MGroupPropagate.Entity.Diff.t list
end

class type group_diffs = object 
  method columns : MGroupColumn.Diff.t list 
  method join    : MJoinFields.Diff.t list 
  method propagate : MGroupPropagate.Entity.Diff.t list
end

val applicable : ('a,'b) version -> 'a list
val applies_to : 'a -> ('a,'b) version list -> ('a,'b) version list
val version : ('a,'b) version -> string
val payload : ('a,'b) version -> 'b list

val template_extract : TemplateDiff.t list -> entity_diffs 

val template_versions : (ITemplate.t,TemplateDiff.t) version list 
val last_template_version : string

val vertical_versions : (IVertical.t,VerticalDiff.t) version list
val last_vertical_version : string

module Admin : sig

  val overwrite_template_versions :  [`Admin] ICurrentUser.id 
    -> (ITemplate.t,TemplateDiff.t) version list
    -> unit O.run

  val create_template_version : [`Admin] ICurrentUser.id 
    -> ITemplate.t list -> TemplateDiff.t list -> unit O.run

  val of_template : [`Admin] ICurrentUser.id
    -> ITemplate.t -> TemplateDiff.t list O.run

  val overwrite_vertical_versions :  [`Admin] ICurrentUser.id 
    -> (IVertical.t,VerticalDiff.t) version list
    -> unit O.run

  val create_vertical_version : [`Admin] ICurrentUser.id
    -> IVertical.t list -> VerticalDiff.t list -> unit O.run

  val of_vertical : [`Admin] ICurrentUser.id
    -> IVertical.t -> VerticalDiff.t list O.run

end
