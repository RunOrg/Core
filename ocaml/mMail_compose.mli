(* © 2013 RunOrg *) 

(* Ugly M -> V dependency, live with it. *)

val setRenderer : 
  (    mid:IMail.t
    -> uid:[`IsSelf] IUser.id
    -> owid:IWhite.t option 
    -> block:bool option
    -> subject:O.i18n
    -> payload:VMailBrick.payload
    -> body:VMailBrick.body
    -> buttons:VMailBrick.button list
    -> ?iid:IInstance.t
    -> ?from:IAvatar.t
    -> unit
    -> VMailBrick.result O.run)
  -> unit
