(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

class type ['level] t = object
  method self             : [`IsSelf] IAvatar.id
  method isin             : 'level IIsIn.id 
  method instance         : MInstance.t
  method iid              : IInstance.t 
end

let make cuid iid instance = 
  let! isin = ohm $ MAvatar.identify iid cuid in
  let! isin = req_or (return None) $ IIsIn.Deduce.is_token isin in
  let! self = ohm $ MAvatar.get isin in 
  return $ Some (object
    method self = self
    method isin = isin
    method instance = instance
    method iid = IInstance.decay iid
  end)

let admin (access : 'any t) = 
  let! isin = req_or None $ IIsIn.Deduce.is_admin (access # isin) in 
  Some (object
    method self     = access # self
    method isin     = isin 
    method instance = access # instance
    method iid      = access # iid
  end)

