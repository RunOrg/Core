(* © 2012 IRunOrg *)

include Ohm.Id.PHANTOM
  
module Assert : sig
  val answer  : 'any id -> [`Answer] id
  val read    : 'any id -> [`Read] id
  val created : 'any id -> [`Created] id
  val bot     : 'any id -> [`Bot] id
end
  
module Deduce : sig
  val created_can_read  : [`Created] id -> [`Read] id
  val read_can_answer   : [`Read] id    -> [`Answer] id
  val answer_can_read   : [`Answer] id  -> [`Read] id
    
  val make_answer_token : [`Unsafe] ICurrentUser.id -> [`Answer] id -> string
  val from_answer_token : [`Unsafe] ICurrentUser.id -> 'any id     -> string -> [`Answer] id option
end
