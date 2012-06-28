(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render comment = 

  let! author  = ohm $ CAvatar.mini_profile (comment # who) in
  let! now     = ohmctx (#time) in

  Asset_Comment_Single.render (object
    method author = author
    method body   = OhmText.format ~nl2br:true ~skip2p:true ~mailto:true ~url:true (comment # what)
    method time   = (comment # time, now) 
    method like   = None
    method remove = None
  end)

let render_by_id cid = 

  let! comment = ohm_req_or (return None) $ MComment.get cid in
  let! html = ohm $ render comment in 
  return (Some html)
