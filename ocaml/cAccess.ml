(* © 2013 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

class type ['level] t = object
  method actor            : 'level MActor.t 
  method self             : [`IsSelf] IAvatar.id
  method instance         : MInstance.t
  method iid              : 'level IInstance.id 
end

let make cuid iid instance = 
  let! actor = ohm_req_or (return None) $ MAvatar.identify iid cuid in
  let! actor = req_or (return None) $ MActor.member actor in
  return $ Some (object
    method self     = MActor.avatar actor
    method actor    = actor
    method instance = instance
    method iid      = MActor.instance actor
  end)

let of_actor actor = 
  let! instance = ohm_req_or (return None) $ MInstance.get (MActor.instance actor) in
  return $ Some (object
    method self     = MActor.avatar actor
    method actor    = actor
    method instance = instance
    method iid      = MActor.instance actor
  end) 

let admin (access : 'any t) = 
  let! actor = req_or None $ MActor.admin (access # actor) in 
  Some (object
    method self     = MActor.avatar actor
    method actor    = actor
    method instance = access # instance
    method iid      = MActor.instance actor
  end)

