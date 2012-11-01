(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let rename key = "/aide/asso/" ^ OhmStatic.canonical key

let help_css = "/AssoHelp/style.css"

let render ?(css=[]) ?(js=[]) ?head ?favicon ?(body_classes=[]) ~title html = 
  Html.print_page
    ~js:(CPageLayout.js false @ js)
    ~css:([Asset.css ; help_css ] @ css)
    ?head
    ~favicon:(ConfigWhite.favicon None)
    ~title
    ~body_classes:("help" :: body_classes)
    html

let wrapper info = 
  Asset_Help_Page.render (object
    method body = info # body
    method home = BatOption.default "" (OhmStatic.Exported.url (info # site) (info # req # server) "index.htm")
    method back = "/me/#/news"
  end) 

let _ = OhmStatic.export 
  ~rename
  ~render:(OhmStatic.extend ~page:render wrapper)
  ~server:O.core 
  ~title:   "Aide en Ligne"
  Static_AssoHelp.site
