(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

let () = UrlMe.Notify.def_follow begin fun req res -> 

  let cuid = CSession.check req in
  let mid, act = req # args in 

  let fail = 
    let html = Asset_NotFound_Page.render (req # server,CSession.decay cuid,None) in
    CPageLayout.core (req # server) `Page404_Title html res
  in

  let confirm = 
    let html = Asset_Client_ConfirmFirst.render (object
      method navbar = (req # server, CSession.decay cuid, None)
    end) in 
    CPageLayout.core (req # server) `Notify_Follow_ConfirmFirst html res
  in
  
  let! cuid = req_or confirm (match cuid with
    | `Old cuid -> Some cuid
    | `New _ | `None -> None) in
 
  let! item = ohm_req_or fail (MMail.from_user mid cuid) in
  
  let! url = ohm (item # act act) in

  return (Action.redirect url res) 
  

end
