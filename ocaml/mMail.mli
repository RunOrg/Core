(* © 2012 RunOrg *)

val other_send_to_self :
     'a IUser.id 
  -> (    [ `IsSelf ] IUser.id
       -> MUser.t
       -> (    owid:IWhite.t option
	    -> from:string option 
            -> subject:string O.run
            -> html:Ohm.Html.writer O.run
            -> unit O.run )
       -> unit O.run )
  -> bool O.run

val send_to_self: 
     'a IUser.id 
  -> (    [ `IsSelf ] IUser.id
       -> MUser.t
       -> (    owid:IWhite.t option
            -> subject:string O.run
            -> html:Ohm.Html.writer O.run
            -> unit O.run) 
       -> unit O.run )
  -> bool O.run
