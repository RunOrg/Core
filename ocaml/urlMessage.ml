(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlClientHelper
open UrlR

let build inst mid =
  let obj = object (self) 
    inherit [MInstance.t] O.Box.controller (r :> MInstance.t O.Box.root_action) ["m"]
    method build inst mid = 
      self # rest inst [IMessage.to_string mid]
  end in
  obj # build inst mid
  
