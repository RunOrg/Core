(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open O
open BatPervasives

let domain_cookie   = 
  let s = "RUNORG_PRESERVE_DOMAIN" in
  if O.environment = `Dev then "DEV_" ^ s else s

let fragment_cookie =
  let s = "RUNORG_PRESERVE_FRAGMENT" in
  if O.environment = `Dev then "DEV_" ^ s else s 

let with_preserve_cookie url response = 
  Action.with_cookie ~name:domain_cookie ~value:url ~life:0 response

let without_preserve_cookie response = 
  Action.with_cookie ~name:domain_cookie ~value:""  ~life:1 response
  |> Action.with_cookie ~name:fragment_cookie ~value:""  ~life:1 

let read_preserve_cookie req = 
  match req # cookie domain_cookie with None -> None | Some domain ->
    match req # cookie fragment_cookie with None -> Some domain | Some fragment ->
      Some (domain ^ fragment)
