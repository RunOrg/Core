(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let search _ key atid = 
  let gid = IGroup.of_id (IAtom.to_id atid) in
  return (Action.url UrlClient.Members.home key [ IGroup.to_string gid ])
    
let () = CAtom.register ~search `Group
