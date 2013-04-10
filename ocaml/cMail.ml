(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Resend      = CMail_resend
module Wrap        = CMail_wrap
module Unsubscribe = CMail_unsubscribe
module Footer      = CMail_footer

let link mid maid owid = 
  Action.url UrlMail.link owid ( mid, MMail.get_token mid, maid )

let () = UrlMail.def_link begin fun req res ->

  let mid, proof, maid = req # args in
  let current = match CSession.check req with 
    | `None     -> None
    | `New _    -> None
    | `Old cuid -> Some cuid 
  in

  let! what = ohm $ MMail.from_token mid ?current proof in
  let  home = Action.url UrlMe.Notify.home (req # server) () in

  match what with 
    | `Valid (n,cuid) -> let uid = IUser.Deduce.is_anyone cuid in 
			 let! ( ) = ohm $ MAdminLog.(log ~uid (Payload.LoginWithMail (n # info # plugin))) in   
			 let! ( ) = ohm $ MNews.Cache.prepare uid in
			 let! ( ) = ohm $ TrackLog.(log (IsUser uid)) in 
			 let! url = ohm (n # act (ICurrentUser.decay cuid) (req # server) maid) in 
			 return $ CSession.start (`Old cuid) (Action.redirect url res)
    | `Missing -> return (Action.redirect home res)
    | `Expired uid -> let title = AdLib.get `Notify_Expired_Title in
		      let html = Asset_Notify_Expired.render (object
			method navbar = (req # server,None,None)
			method title  = title 
		      end) in
		      let! () = ohm $ MNews.Cache.prepare uid in
		      let! () = ohm $ Resend.schedule ~mid ~uid ~act:maid in 
		      CPageLayout.core (req # server) `Notify_Expired_Title html res	


end
