(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "me" A.none
let ajax, def_ajax = O.declare O.core "me/ajax" (A.n A.string)

let url owid list = 
  OhmBox.url (Action.url root owid ()) list 

let declare ?p url = 
  let endpoint, define = O.declare O.core ("me/ajax/" ^ url) (A.n A.string) in
  let endpoint = Action.setargs (Action.rewrite endpoint "me/ajax" "me/#") [] in
  let root owid = Action.url root owid () in
  let prefix = "/" ^ url in
  let parents = match p with 
    | None -> [] 
    | Some (_,prefix,parents,_) -> parents @ [prefix] 
  in
  endpoint, (root,prefix,parents,define)

let root url = declare url 
let child p url = declare ~p url 

module Account = struct
  let home,    def_home    = root "account"
  let admin,   def_admin   = child def_home  "admin/account"
  let edit,    def_edit    = child def_admin "edit/profile"
  let pass,    def_pass    = child def_admin "edit/password"
  let picture, def_picture = child def_admin "edit/picture"
  let picpost, def_picpost = O.declare O.core "edit/picture/post" A.none
end

module Notify = struct
  let home, def_home = root "notify"
  let count, def_count = O.declare O.core "notify/count" A.none
  let follow, def_follow = O.declare O.core "notify/follow" (A.r INotify.arg) 
  let mailed, def_mailed = O.declare O.core "nt" (A.rr INotify.arg A.string)
  let settings, def_settings = child def_home "nt/settings" 
  let link, def_link = O.declare O.core "ntfy" (A.rro IMail.arg A.string IMail.Action.arg) 
end
  
module News = struct
  let home, def_home = root "news"
end
