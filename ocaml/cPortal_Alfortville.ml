(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let owid = Some ConfigWhite.alfort

let splash_css = "/Alfortville/splash.css"

let render ?(css=[]) ?(js=[]) ?head ?favicon ?(body_classes=[]) ~title html = 
  Html.print_page
    ~js:(CPageLayout.js false @ js)
    ~css:([Asset.css] @ CPageLayout.white_css owid @ [ splash_css ] @ css)
    ?head
    ~favicon:(ConfigWhite.favicon owid)
    ~title
    ~body_classes:("splash" :: body_classes)
    html

let wrapper info = 
  return (info # body)

let _ = OhmStatic.export 
  ~render:(OhmStatic.extend ~page:render wrapper)
  ~server:(O.server owid) 
  ~title:   "Alfortville"
  Static_Alfortville.site
