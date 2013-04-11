(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Include alias module trick... *)

module Inc = struct
  module Status    = MMembership_status
  module Details   = MMembership_details 
  module Reflected = MMembership_reflected
  module Versioned = MMembership_versioned
end
open Inc

(* Full type returned for more clarity ----------------------------------------------------- *)

type t = {
  where     : IAvatarSet.t  ;
  who       : IAvatar.t ;
  admin     : (bool * float * IAvatar.t) option ;
  user      : (bool * float * IAvatar.t) option ;
  invited   : (bool * float * IAvatar.t) option ;
  paid      : (bool * float * IAvatar.t) option ;
  mustpay   : bool ;
  grant     : [ `Admin | `Token ] option ;
  admin_act : bool ;
  user_act  : bool ;
  time      : float ;
  status    : Status.t
}

let summary current reflected = {
  where     = current.Details.where ; 
  who       = current.Details.who ;
  admin     = current.Details.admin ;
  user      = current.Details.user ;
  invited   = current.Details.invited ;
  paid      = current.Details.paid ;
  mustpay   = reflected.Reflected.mustpay ;
  grant     = reflected.Reflected.grant ;
  admin_act = reflected.Reflected.admin_act ;
  user_act  = reflected.Reflected.user_act ;
  time      = reflected.Reflected.time ;
  status    = reflected.Reflected.status
}

let default ~mustpay ~group ~avatar = 
  summary (Details.default group avatar) (Reflected.default mustpay)

(* Extract values ------------------------------------------------------------------------ *)

let get mid = 
  let! data = ohm_req_or (return None) $ Versioned.get (IMembership.decay mid) in
  return $ Some (summary (Versioned.current data) (Versioned.reflected data))
