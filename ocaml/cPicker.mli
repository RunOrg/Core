(* © 2012 RunOrg *)

type 't result

val node : icon:string -> title:string -> 't -> 't result
val item : icon:string -> title:string -> Ohm.JsCode.t -> 'any result

module type TREE = sig

  type t 
  type param 
    
  val of_json : Json_type.t -> t
  val to_json : t -> Json_type.t

  val node : param -> Ohm.I18n.t -> t -> t result list O.run   

end

module Make : functor (Tree:TREE) -> sig

  val at_root : 
       root:Tree.t
    -> param:Tree.param
    -> me:'any ICurrentUser.id     
    -> url:(string -> string) 
    -> i18n:Ohm.I18n.t
    -> Ohm.View.Context.box Ohm.View.t O.run

  val at_node : 
       arg:string 
    -> param:Tree.param
    -> me:'any ICurrentUser.id 
    -> url:(string -> string) 
    -> i18n:Ohm.I18n.t 
    -> Ohm.View.Context.box Ohm.View.t option O.run

end
