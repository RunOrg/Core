(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render cuid key iid = 

  let! num_brc = ohm $ MBroadcast.count iid in 
  let! num_sbs = ohm $ MDigest.Subscription.count_followers iid in 
  
  let! follows = ohm begin match cuid with 
    | None      -> return false
    | Some cuid -> MDigest.Subscription.follows cuid iid 
  end in

  let  the_url = UrlClient.(if follows then unsubscribe else subscribe) in

  Asset_Website_Subscribe.render (object
    method num_brc = num_brc
    method num_sbs = num_sbs
    method url     = Action.url the_url key () 
    method follows = follows
  end) 

let respond cuid key iid res = 
  let! html = ohm $ render cuid key iid in
  return $ Action.json ["replace", Html.to_json html] res
   
let () = UrlClient.def_subscribe begin fun req res -> 

  if req # post = None then return res else 

    let! cuid, key, iid, _ = CClient.extract_ajax req res in
    
    let! () = ohm begin match cuid with 
      | None -> return () 
      | Some cuid -> MDigest.Subscription.subscribe cuid iid 
    end in
    
    respond cuid key iid res

end

let () = UrlClient.def_unsubscribe begin fun req res -> 

  if req # post = None then return res else 

    let! cuid, key, iid, _ = CClient.extract_ajax req res in
    
    let! () = ohm begin match cuid with 
      | None -> return () 
      | Some cuid -> MDigest.Subscription.unsubscribe cuid iid 
    end in
    
    respond cuid key iid res

end
