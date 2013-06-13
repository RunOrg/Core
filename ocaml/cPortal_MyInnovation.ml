(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let owid = Some ConfigWhite.innov

let splash_css = [
  "/MyInnovation/stylesheets/reset.css" ;
  "/MyInnovation/stylesheets/fonts.css" ;
  "/MyInnovation/stylesheets/home.css"
]

let render ?(css=[]) ?(js=[]) ?head ?favicon ?(body_classes=[]) ~title html = 
  Html.print_page
    ~js:(CPageLayout.js false @ js)
    ~css:(splash_css @ css)
    ?head
    ~favicon:(ConfigWhite.favicon owid)
    ~title
    ~body_classes:("splash" :: body_classes)
    html

let wrapper info = 
  Asset_MyInnovation_Page.render (object
    method body = info
    method head = OhmStatic.get_page (info # site) (info # req) "blocks/head.htm"
    method foot = OhmStatic.get_page (info # site) (info # req) "blocks/foot.htm"
  end)

let _ = OhmStatic.export 
  ~render:(OhmStatic.extend ~page:render wrapper)
  ~server:(O.server owid) 
  ~title:   "My Innovation"
  Static_MyInnovation.site
