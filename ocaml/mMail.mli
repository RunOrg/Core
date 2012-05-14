(* © 2012 RunOrg *)

open Ohm

val other_send_to_self :
     'a IUser.id 
  -> (    [ `IsSelf ] IUser.id
       -> MUser.t
       -> (    from:string option 
            -> subject:View.text 
            -> text:View.text 
            -> html:View.text option
            -> unit O.run )
       -> unit O.run )
  -> bool O.run

val send_to_self: 
     'a IUser.id 
  -> (    [ `IsSelf ] IUser.id
       -> MUser.t
       -> (    subject:View.text
	    -> text:View.text 
            -> html:View.text option
            -> unit O.run) 
       -> unit O.run )
  -> bool O.run
