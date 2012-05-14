(* © 2012 RunOrg *)

val register : 
     ?fail:(Ohm.I18n.t -> O.Action.response -> O.Action.response)
  -> # O.Action.controller
  -> (    Ohm.I18n.t 
       -> IInstance.t * MInstance.t
       -> O.Action.request
       -> O.Action.response
       -> O.Action.response O.run )
  -> unit

module User : sig

  val register : 
       ?fail:(Ohm.I18n.t -> O.Action.response -> O.Action.response)
    -> ([ `Unknown ] IIsIn.id -> 'a IIsIn.id option)
    -> #O.Action.controller
    -> (   'a CContext.full 
	 -> O.Action.request
	 -> O.Action.response 
	 -> O.Action.response O.run)
    -> unit

  val register_ajax : 
       ?fail:(Ohm.I18n.t -> O.Action.response -> O.Action.response)
    -> ([ `Unknown ] IIsIn.id -> 'a IIsIn.id option)
    -> #O.Action.controller
    -> (   'a CContext.full 
	 -> O.Action.request
	 -> O.Action.response 
	 -> O.Action.response O.run)
    -> unit

end

val is_anyone  : 'any IIsIn.id -> [ `Unknown   ] IIsIn.id option
val is_contact : 'any IIsIn.id -> [ `IsContact ] IIsIn.id option
val is_token   : 'any IIsIn.id -> [ `IsToken   ] IIsIn.id option
val is_admin   : 'any IIsIn.id -> [ `IsAdmin   ] IIsIn.id option
