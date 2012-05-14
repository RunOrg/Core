(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlClientHelper

let index  = new dflt "" 

let r      = new dflt "r"
let r_ajax = new dflt "r/*"

let ajax segs = new ajax (r :> MInstance.t O.Box.root_action) segs

let build inst segs data = 
  (ajax (O.Box.Seg.to_url segs data)) # build inst
    
let build_post inst segs data (prefix,name) = 
  (new rest "r") # rest inst (O.Box.Seg.to_url segs data @ [prefix^"."^name])
    
let builder inst =
  (new rest "r") # rest inst

let home        = ajax [ "home" ]
let wall        = ajax [ "home" ; "wall" ]
let chat        = ajax [ "home" ; "chat" ]
let feed        = ajax [ "home" ; "feed" ]
let start       = ajax [ "home" ; "start" ]
