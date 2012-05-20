(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let large pic = 
  let! pic = ohm $ Run.opt_bind (fun fid -> MFile.Url.get fid `Large) pic in
  return $ BatOption.default "/public/img/404_large.png" pic
