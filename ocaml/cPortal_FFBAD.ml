(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let owid = Some ConfigWhite.ffbad

let splash_css = "/FFBAD/splash.css"

let render ?(css=[]) ?(js=[]) ?head ?favicon ?(body_classes=[]) ~title html = 
  Html.print_page
    ~js:(CPageLayout.js false @ js)
    ~css:([Asset.css] @ CPageLayout.white_css owid @ [ splash_css ] @ css)
    ?head
    ~favicon:(ConfigWhite.favicon owid)
    ~title
    ~body_classes:("splash" :: body_classes)
    html

let _ = OhmStatic.export 
  ~render:(OhmStatic.custom_render render)
  ~server:(O.server owid) 
  ~title:   "FFBAD"
  Static_FFBAD.site
