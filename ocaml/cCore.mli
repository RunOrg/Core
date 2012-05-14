(* © 2012 Runorg *)

val js_fail : Ohm.JsCode.t -> O.Action.response -> O.Action.response O.run
val build_js_fail_message  : Ohm.I18n.t -> string -> O.Action.response -> O.Action.response
val js_fail_message : Ohm.I18n.t -> string -> O.Action.response -> O.Action.response O.run
val json_fail : (string * Json_type.t) list -> O.Action.response -> O.Action.response O.run
val redirect_fail : string -> O.Action.response -> O.Action.response O.run

val css_core   : string list
val css_splash : string list
val css_client : string list

val js_splash  : string list
val js_catalog : string list

val render : 
     ?navbar:Ohm.View.Context.box Ohm.View.t O.run
  -> ?start:Ohm.View.Context.box Ohm.View.t O.run
  -> ?js:Ohm.JsCode.t 
  -> ?js_files:string list 
  -> ?css:string list 
  -> ?theme:(string * [`RunOrg | `White])
  ->  title:Ohm.View.Context.text Ohm.View.t O.run
  ->  body:Ohm.View.Context.box Ohm.View.t O.run
  ->  O.Action.response
  ->  O.Action.response O.run

val error500 : Ohm.I18n.t -> O.Action.response -> O.Action.response
val error500_js : Ohm.I18n.t -> O.Action.response -> O.Action.response

val profileSessionRegister : 
     # O.Action.controller
  -> (    string
       -> O.Action.request
       -> O.Action.response
       -> O.Action.response )
  -> unit

val profileRegister : 
     # O.Action.controller
  -> (    O.Action.request
       -> O.Action.response
       -> O.Action.response )
  -> unit

val register :
     ?fail:(Ohm.I18n.t -> O.Action.response -> O.Action.response) 
  -> # O.Action.controller
  -> (    Ohm.I18n.t
       -> O.Action.request
       -> O.Action.response
       -> O.Action.response O.run )
  -> unit

module User : sig

  val register : 
       # O.Action.controller
    -> (    Ohm.I18n.t
	 -> [`Safe] ICurrentUser.id 
         -> O.Action.request
         -> O.Action.response
         -> O.Action.response O.run )
    -> unit

  val register_ajax :
       # O.Action.controller
    -> (    Ohm.I18n.t
	 -> [`Safe] ICurrentUser.id 
         -> O.Action.request
         -> O.Action.response
         -> O.Action.response O.run )
    -> unit

end

val navbar : 
     string
  -> 'any ICurrentUser.id 
  -> string
  -> IInstance.t option
  -> MNotification.Count.t
  -> int
  -> Ohm.I18n.t
  -> Ohm.View.Context.box Ohm.View.t O.run
