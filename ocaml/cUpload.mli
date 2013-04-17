(* © 2013 RunOrg *)

val form : 
     IWhite.t option 
  -> ([<`PutDoc|`PutImg|`PutPic] as 'b) IOldFile.id 
  -> ( Ohm.Html.writer O.run -> Ohm.Html.writer O.run) 
  -> ( Ohm.Html.writer -> Ohm.Html.writer O.run) 
  -> ( 'b IOldFile.id -> 'result) 
  -> ( IOldFile.t * 'result -> string)
  -> Ohm.Action.response
  -> Ohm.Action.response O.run 
