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

module Account = struct
  let prefix = "account"
  let _, def = O.declare O.core ("me/ajax/" ^ prefix) (A.n A.string)
  let root = url [prefix]
end

module Network = struct
  let prefix = "network"
  let _, def = O.declare O.core ("me/ajax/" ^ prefix) (A.n A.string) 
  let root = url [prefix] 
end

module News = struct
  let prefix = "news"
  let _, def = O.declare O.core ("me/ajax/" ^ prefix) (A.n A.string) 
  let root = url [prefix] 
end
