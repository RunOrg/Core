(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type what = string (* The URL where the like should be posted. *)

let () = UrlClient.Like.def_item $ CClient.action begin fun access req res -> 
  
  let  fail = return res in
  let  cuid = IIsIn.user (access # isin) in

  let  itid, proof = req # args in
  let! itid = req_or fail $ IItem.Deduce.from_like_token cuid itid proof in
  let  what = `item itid in
  
  let! json = req_or fail $ Action.Convenience.get_json req in
  let  like = json = Json.Bool true in

  let! () = ohm begin
    if like then
      MLike.like (access # self) what
    else
      MLike.unlike (access # self) what
  end in 

  let! count = ohm $ MLike.count what in
  
  return $ Action.json ["like", Json.Bool like ; "count", Json.Int count ] res

end

let item access itid = 
  Action.url UrlClient.Like.item (access # instance # key) 
    ( let cuid = IIsIn.user (access # isin) in
      let proof = IItem.Deduce.(make_like_token cuid (read_can_like itid)) in
      (IItem.decay itid, proof) ) 

let render what likes count = 
  Asset_Like_Button.render (object
    method url   = what 
    method count = count
    method likes = likes
  end)

 
