(* © 2012 RunOrg *)

open Ohm
open UrlCommon
open UrlClientHelper
open UrlR

let page ctx avatar = 
  let obj = object (self) 
    inherit [MInstance.t] O.Box.controller (r :> MInstance.t O.Box.root_action) ["p"]
    method build inst avatar = 
      self # rest inst [IAvatar.to_string avatar]
  end in
  
  obj # build ctx # instance avatar
