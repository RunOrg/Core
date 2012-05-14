(* © 2012 RunOrg *)

type t  = Ohm.JsCode.t
type id = Ohm.Id.t
type view = Ohm.View.Context.box Ohm.View.t
type jsont = Json_type.t

module Dialog : sig
  val create : ?options:(string * jsont) list -> view -> string -> t
  val close  : t 
end

val maxFieldLength : int -> id -> t

val picUploader: 
     id:id 
  -> url_get:string 
  -> url_put:string 
  -> title:string
  -> t

val datepicker : string -> lang:[`Fr] -> ancient:bool -> t

module Start : sig
  val refresh : view option -> t
end

(* Old, unclean code ------------------------------------------------------------------------ *)

val init : t
val assoKey : string -> t
val refreshDelayed : t
val jQuery : string -> string -> jsont list -> t
val editsJoin : jid:id -> url:string -> sel:id -> t
val appendList : id -> view -> t
val appendUniqueList : id -> view -> id -> t
val replaceInList : id -> view -> t
val onLoginPage : string -> t
val onClick : string -> t -> t
val redirect : string -> t
val hideLabel : id -> t
val onChange : string -> t -> t
val toggleParent : id -> string -> string -> t
val removeParent : string -> t
val wallPost : id -> view -> t
val like : string -> t
val moreReplies : string -> t
val wait : string -> t -> t
val unloggedRedirect : login:string -> t

val setField : 
     ?overwrite:bool 
  ->  id 
  ->  string 
  ->  t

val setFieldAsync : 
     ?overwrite:bool 
  ->  id 
  ->  Ohm.JsBase.source 
  ->  t

val message : view -> t

val askServer: string -> (string * id) list -> (string * jsont) list -> Ohm.JsBase.source

val refresh : t
val setTrigger : string -> t -> t
val runTrigger : string -> t
val panic : t
val sendSelected : string -> t
val notify : id:[`message|`news] -> unread:int -> total:int -> t
val runFromServer : ?disable:bool -> ?args:jsont -> string -> t
val appendReply : id -> view -> t
val assignPicked : id -> id -> t 
val sendPicked : id -> string -> t
val sendList : id -> string -> t
val picker : id -> t
val verticalPicker : id -> t
val replaceWith : string -> view -> t
val replaceOtherWith : string -> view -> t
val autocomplete : id -> id -> string -> t
val sortable : id -> id -> string -> t
val lazyPick : string -> string -> t
val lazyNext : string -> t

val return : t -> jsont

module Html : sig
  val return : view -> (string * jsont) list
end

module More : sig
  val fetch  : ?args:(string * Json_type.t) list -> string -> t
  val return : view -> (string * jsont) list
end

(* val showProfile : string -> Ohm.Breathe.Profiling.profile -> t *)

module Grid : sig

  type column

  val column : 
       ?index:int 
    -> ?width:int 
    -> ?render:Ohm.JsBase.render 
    -> ?label:string
    -> ?sort:bool
    ->  unit -> column

  val grid: 
       id:id 
    -> url:string 
    -> cols:column list 
    -> edit:string
    -> t

  val return : 
       rows:jsont list list
    -> next:(jsont * id) option
    -> (string * jsont) list

end

module Admin : sig
  val joy : id -> Ohm.JoyA.t -> (string * (string list)) list -> t
end
