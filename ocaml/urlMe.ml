(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlCoreHelper

let me            = new dflt "me"           
let me_ajax       = new dflt "me/*"

let build segs data = 
  (new ajax (me :> unit O.Box.root_action) (O.Box.Seg.to_url segs data)) # build 
    
let build_post segs data (prefix,name) = 
  (new rest "me") # rest (O.Box.Seg.to_url segs data @ [prefix^"."^name])

let builder =
  (new rest "me") # rest 
    
let assos_create  = new dflt "me/post/assos/new"

let setpass       = new dflt "me/post/account/pass"
  
let messages      = new dflt "me/messages"
  
