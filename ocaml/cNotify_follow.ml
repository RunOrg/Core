(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal

let () = Url.def_follow begin fun req res -> 

  let cuid = CSession.get req in
  let mid, act = req # args in 

  let fail = 
    let html = Asset_NotFound_Page.render (req # server,cuid,None) in
    CPageLayout.core owid `Page404_Title html res
  in
  
  let! cuid = req_or fail cuid in 
  let! item = ohm_req_or fail (MMail.from_user mid cuid) in
  
  let! url = ohm (item # act cuid (req # server) act) in

  return (Action.redirect url res) 
  

end
