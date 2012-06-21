(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render_page iid server start = 
  let! broadcasts, next = ohm $ MBroadcast.latest ?start ~count:5 iid in
  let! list = ohm $ CBroadcast.render_list broadcasts in 
  let! more = ohm begin match next with 
    | None -> return $ Html.str "" 
    | Some time -> let url = Action.url UrlClient.articles server time in
		   Asset_Broadcast_More.render url
  end in 
  return (Html.concat [ list ; more ]) 
