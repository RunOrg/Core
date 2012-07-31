(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let admin_only body req res = 
  
  let  cuid = CSession.get req in
  let  e404 = C404.render cuid res in

  let! cuid = req_or e404 $ BatOption.bind MAdmin.user_is_admin cuid in 

  body cuid req res

let page cuid title view res = 

  let! view = ohm $ Asset_Admin_Page.render view in 
  let! nav  = ohm $ VNavbar.intranet (Some (ICurrentUser.decay cuid), None) in
  let! foot = ohm $ Asset_PageLayout_Footer.render () in
  let  html = Html.concat [ nav ; view ; foot ] in
  return $ Action.page 
    (Html.print_page 
       ~js:(CPageLayout.js ~deeplink:false)
       ~css:[Asset.css] 
       ~favicon:"/public/favicon.ico"
       ~title html) res




    
