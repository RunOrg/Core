(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let access iid self = 
  let! isin = ohm $ MAvatar.identify_user iid self in
  let! isin = req_or (return None) $ IIsIn.Deduce.is_token isin in
  let! self = ohm $ MAvatar.get isin in 
  return $ Some (object
    method self = self
    method isin = isin
  end)
