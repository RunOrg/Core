(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render iid = 

  let! num_brc = ohm $ MBroadcast.count iid in 
  let! num_sbs = ohm $ MDigest.Subscription.count_followers iid in 
  
  Asset_Website_Subscribe.render (object
    method num_brc = num_brc
    method num_sbs = num_sbs
  end) 
   
let () = UrlClient.def_subscribe begin fun req res -> 

  return res

end

let () = UrlClient.def_unsubscribe begin fun req res -> 

  return res

end
