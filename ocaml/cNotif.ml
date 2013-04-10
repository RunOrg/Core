(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

module Send = CNotif_send
module Resend = CNotif_resend

let link nid naid owid = 
  Action.url UrlMe.Notify.link owid ( nid, MNotif.get_token nid, naid )

let () = UrlMe.Notify.def_link begin fun req res ->

  let nid, proof, naid = req # args in
  let current = match CSession.check req with 
    | `None     -> None
    | `New _    -> None
    | `Old cuid -> Some cuid 
  in

  let! what = ohm $ MNotif.from_token nid ?current proof in
  let  home = Action.url UrlMe.Notify.home (req # server) () in

  match what with 
    | `Valid (n,cuid) -> let uid = IUser.Deduce.is_anyone cuid in 
			 let! ( ) = ohm $ MAdminLog.(log ~uid (Payload.LoginWithNotify (n # plugin))) in   
			 let! ( ) = ohm $ MNews.Cache.prepare uid in
			 let! ( ) = ohm $ TrackLog.(log (IsUser uid)) in 
			 let! url = ohm (n # act naid) in 
			 return $ CSession.start (`Old cuid) (Action.redirect url res)
    | `Missing -> return (Action.redirect home res)
    | `Expired uid -> let title = AdLib.get `Notify_Expired_Title in
		      let html = Asset_Notify_Expired.render (object
			method navbar = (req # server,None,None)
			method title  = title 
		      end) in
		      let! () = ohm $ MNews.Cache.prepare uid in
		      let! () = ohm $ Resend.schedule ~nid ~uid ~act:naid in 
		      CPageLayout.core (req # server) `Notify_Expired_Title html res	


end
