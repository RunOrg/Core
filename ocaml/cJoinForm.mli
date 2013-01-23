 (* © 2012 RunOrg *)

 val box :
      [`IsToken] CAccess.t
   -> IAvatarSet.t
   -> (Ohm.Html.writer O.run -> O.Box.result O.boxrun)
   -> O.Box.result O.boxrun
