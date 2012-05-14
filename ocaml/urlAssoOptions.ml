(* © 2012 RunOrg *)

open Ohm
open UrlClientHelper
open UrlR

let home = ajax [ "home" ; "asso" ]

let client instance = 
  let base = O.Box.Seg.(UrlSegs.(root ++ root_pages ++ home_pages ++ client_tabs `Client)) in
  UrlR.build instance base ((((),`Home),`Client),`Client)

let order ctx oid = 
  let base = 
    O.Box.Seg.(UrlSegs.(
      root
      ++ root_pages
      ++ home_pages
      ++ client_tabs `Order
      ++ order_id
      ++ string
    ))
  in		
 
  let iid   = IInstance.decay (IIsIn.instance (ctx # myself)) in
  let user  = IIsIn.user (ctx # myself) in
  let proof = IRunOrg.Order.Deduce.make_edit_token user iid oid in
  let oid   = IRunOrg.Order.decay oid in 

  let instance = ctx # instance in 
  
  UrlR.build instance base ((((((),`Home),`Client),`Order),Some oid),Some proof)

let edit_order ctx oid = 

  let base = 
    O.Box.Seg.(UrlSegs.(
      root 
      ++ root_pages
      ++ home_pages
      ++ client_tabs `Order
      ++ order_id
      ++ string
    ))
  in		
 
  let iid   = IInstance.decay (IIsIn.instance (ctx # myself)) in
  let user  = IIsIn.user (ctx # myself) in
  let proof = IRunOrg.Order.Deduce.make_edit_token user iid oid in
  let oid   = IRunOrg.Order.decay oid in 

  let instance = ctx # instance in 
  
  UrlR.build instance base ((((((),`Home),`Client),`Buy),Some oid),Some proof)
