(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let owid = Some ConfigWhite.m2014

let splash_css = "/M2014/style.css"
let splash_js  = "/M2014/script.js"

let render ?(css=[]) ?(js=[]) ?head ?favicon ?(body_classes=[]) ~title html = 
  Html.print_page
    ~js:(CPageLayout.js false @ [splash_js] @ js)
    ~css:([Asset.css] @ CPageLayout.white_css owid @ [ splash_css ] @ css)
    ?head
    ~favicon:(ConfigWhite.favicon owid)
    ~title
    ~body_classes:("splash" :: body_classes)
    html

let wrapper body = 
  Asset_M2014_Page.render (object
    method body = body
  end)

let _ = OhmStatic.export 
  ~render:(OhmStatic.extend ~page:render wrapper)
  ~server:(O.server owid) 
  ~title:   "M0214.fr"
  Static_M2014.site
