(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let reply access itid = 

  let! myself = ohm $ CAvatar.mini_profile (access # self) in

  let url = Action.url UrlClient.Comment.post (access # instance # key) 
    ( let cuid = MActor.user (access # actor) in
      let proof = IItem.Deduce.make_reply_token cuid itid in
      (IItem.decay itid, proof) ) 
  in

  Asset_Comment_Form.render (object
    method url     = url
    method picture = myself # pic
  end)


let render comment = 

  let! author  = ohm $ CAvatar.mini_profile (comment # who) in
  let! now     = ohmctx (#time) in

  Asset_Comment_Single.render (object
    method author = author
    method body   = comment # what
    method time   = (comment # time, now) 
    method like   = None
    method remove = None
  end)

let render_by_id cid = 

  let! comment = ohm_req_or (return None) $ MComment.get cid in
  let! html = ohm $ render comment in 
  return (Some html)

let () = UrlClient.Comment.def_post $ CClient.action begin fun access req res -> 
  
  let  fail = return res in
  let  cuid = MActor.user (access # actor) in

  let  itid, proof = req # args in
  let! itid = req_or fail $ IItem.Deduce.from_reply_token cuid itid proof in
  
  let! json = req_or fail $ Action.Convenience.get_json req in
  let! text = req_or fail $ try Some (Json.to_string json) with _ -> None in
  
  let  text = BatString.strip text in
  let!  ()  = true_or fail (text <> "") in
  
  let! _, comment = ohm $ MComment.create itid (access # self) text in

  let! html = ohm $ render comment in 
 
  return $ Action.json ["comment", Html.to_json html ] res

end
