(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "me" A.none
let ajax, def_ajax = O.declare O.core "me/ajax" (A.n A.string)

let url list = 
  OhmBox.url (Action.url root () ()) list 

let declare ?p url = 
  let endpoint, define = O.declare O.core ("me/ajax/" ^ url) (A.n A.string) in
  let endpoint = Action.setargs (Action.rewrite endpoint "me/ajax" "me/#") [] in
  let root = Action.url root () () in
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
  let privacy, def_privacy = child def_admin "edit/privacy"
  let picture, def_picture = child def_admin "edit/picture"
end
  
module Network = struct
  let home, def_home = root "network"
end

module News = struct
  let home, def_home = root "news"
end
