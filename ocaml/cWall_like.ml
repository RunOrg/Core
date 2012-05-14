(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open O
open Ohm.Universal


let () = CClient.User.register CClient.is_contact (UrlWall.like_item ())
  begin fun ctx request response -> 
    
    let respond bool = Action.json [ "ok", Json_type.Build.bool bool ] response in
    
    let! item_id = req_or (return (respond false)) (request # args 0) in
    let! item_p  = req_or (return (respond false)) (request # args 1) in
    
    let item_id = IItem.of_string item_id in
    
    let! item = req_or (return (respond false))
      (IItem.Deduce.from_like_token (IIsIn.user (ctx # myself)) item_id item_p) in      
    
    let like = (request # post "like") = Some "1" in
    
    let! self = ohm (ctx # self) in
    
    let! () = ohm (          
      if like then 
	MLike.like   self (`item item)
      else
	MLike.unlike self (`item item)
    ) in
    
    return (respond true)
      
  end
