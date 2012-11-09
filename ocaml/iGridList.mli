(* © 2012 RunOrg *)

(* {{{{* )
type 'relation id

val to_string : 'any id -> string
val to_id     : 'any id -> Ohm.Id.t
  
val make : id:Ohm.Id.t -> [`None] id
  
module Assert : sig
  val make : 
       role:[`Config|`Edit|`List|`None] 
    -> id:Ohm.Id.t
    -> [`None] id
    
  val can_edit   : id:Ohm.Id.t -> [`Edit] id
  val can_list   : id:Ohm.Id.t -> [`List] id
  val can_config : id:Ohm.Id.t -> [`Config] id

  val bot : 'any id -> [`Bot] id
end
  
module Deduce : sig
  val can_list : 'any id -> [`List] id option
  val can_config : 'any id -> [`Config] id option
  val can_edit : 'any id -> [`Edit] id option
  val list : [<`Edit|`List] id -> [`List] id
  val make_list_token : 'a ICurrentUser.id -> [`List] id -> string
  val from_list_token : 'a ICurrentUser.id -> 'any id -> string -> [`List] id option
end

( *|||| *)
(* }}}} *)
