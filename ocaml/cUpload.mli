(* © 2013 RunOrg *)

val form : 
     IWhite.t option 
  -> ([<`PutDoc|`PutImg|`PutPic] as 'b) IFile.id 
  -> ( Ohm.Html.writer O.run -> Ohm.Html.writer O.run) 
  -> ( Ohm.Html.writer -> Ohm.Html.writer O.run) 
  -> ( 'b IFile.id -> 'result) 
  -> ( IFile.t * 'result -> string)
  -> Ohm.Action.response
  -> Ohm.Action.response O.run 
