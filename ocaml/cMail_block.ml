(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Footer = CMail_footer

let prove uid iid = 
  (* Ugly, but we need it to ensure that such links never go stale... 
     Also don't make an URL too long : keep it identifier-sized. *)
  String.sub
    (ConfigKey.passhash (IUser.to_string uid ^ "-" ^ IInstance.to_string iid))
    2 11

let link owid uid iid mid allow = 
  let proof = (if allow then "Y" else "N") ^ prove uid iid in
  Action.url UrlMail.post_block owid (IUser.decay uid,IInstance.decay iid,mid,proof)

let () = UrlMail.def_post_block begin fun req res -> 
  
  let owid = req # server in 
  let uid, iid, mid, proof = req # args in
  let block = BatString.starts_with proof "N" in
  let proof = BatString.tail proof 1 in
  
  (* Make sure that the proof is valid *)

  let e404 =   
    let html = Asset_NotFound_Page.render (owid,None,None) in
    CPageLayout.core owid `Page404_Title html res
  in

  let! () = true_or e404 (prove uid iid = proof) in

  (* Apply changes to database. *) 

  let  uid = IUser.Assert.is_self uid in 
  let! ( ) = ohm (MMail.Spam.set ~mid uid iid (not block)) in

  (* Render an appropriate page *)

  let title = `Mail_Block_Title block in
  let html  = Asset_Mail_BlockConfirm.render (object
    method navbar = (req # server,None,Some iid)
    method block  = block 
    method title  = AdLib.get title
  end) in

  CPageLayout.core owid title html res
	  
end
