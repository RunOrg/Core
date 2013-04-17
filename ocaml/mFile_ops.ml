(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let delete h = 
  return () 

let uploader h = 
  return None

let upload store author ~public ~filename local = 
  return None

let register h author ~size ~filename = 
  return () 
