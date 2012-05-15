(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let build ~uid ~iid = 
  return (object
    method home    = ""
    method account = None
    method menu    = None
    method asso    = None
  end)
