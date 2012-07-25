(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let render ?iid cuid res = 
  let html = Asset_NotFound_Page.render (cuid,iid) in
  CPageLayout.core `Page404_Title html res
