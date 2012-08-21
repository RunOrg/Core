(* © 2012 RunOrg *)

val post : 
     'any CAccess.t
  -> [`Write] MFeed.t
  -> Ohm.Json.t
  -> Ohm.Action.response
  -> Ohm.Action.response O.run

val render :
     ?moderate:(IItem.t -> string)
  ->  'any CAccess.t
  ->  MItem.item
  ->  Ohm.Html.writer option O.run
