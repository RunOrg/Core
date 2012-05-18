(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let render ?iid uid (body:Html.writer O.run) = 
  let! ins = ohm $ Run.opt_bind MInstance.get iid in
  let unsubscribe = Action.url UrlMail.unsubscribe () 
    (IUser.decay uid, iid) in
  let instance = BatOption.map (fun ins -> (object
    method url  = Action.url UrlClient.website (ins # key) []  
    method name = ins # name
  end )) ins in 
  let writer = Asset_Mail_Template.render (object
    method body        = body
    method instance    = instance
    method unsubscribe = unsubscribe
  end) in
  return (BatOption.map (#name) ins, writer) 

