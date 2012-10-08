(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let render ?iid owid cuid res = 
  let html = Asset_NotFound_Page.render (owid,cuid,iid) in
  CPageLayout.core owid `Page404_Title html res
