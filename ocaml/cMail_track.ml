(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let  white = "GIF89a\001\000\001\000\128\000\000\000\000\000\255\255\255!\249\004\001\000\000\000\000,\000\000\000\000\001\000\001\000\000\002\001D\000;"

let () = UrlMail.def_track begin fun req res -> 
  let  mid = req # args in 
  let! ( ) = ohm (MMail.track mid) in 
  return (Action.raw ~mime:"image/gif" ~data:white res) 
end
