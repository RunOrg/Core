(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

module A = Action.Args

let root, def_root = O.declare O.core "me" A.none
let ajax, def_ajax = O.declare O.core "me/ajax" (A.n A.string)

let url list = 
  Action.url root () () ^ "/#/" ^ String.concat "/" 
    (List.map Netencoding.Url.encode list)

let declare url = 
  let endpoint, define = O.declare O.core ("me/ajax/" ^ url) (A.n A.string) in
  Action.setargs (Action.rewrite endpoint "me/ajax" "me/#") [], define

module Account = struct
  let home, def_home = declare "account"
  let edit, def_edit = declare "edit-account"
end
  
module Network = struct
  let home, def_home = declare "network"
end

module News = struct
  let home, def_home = declare "news"
end
