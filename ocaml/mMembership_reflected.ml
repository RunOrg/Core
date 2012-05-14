(* © 2012 MRunOrg *)

open Ohm
open Ohm.Universal

module Status  = MMembership_status
module Details = MMembership_details 

module T = struct

  module Float = Fmt.Float

  type json data = {
    grant     : [ `Admin "a" | `Token "t" ] option ;
    admin_act : bool ;
    user_act  : bool ;
    time      : Float.t ;
    status    : Status.t ; 
    mustpay   : bool 
  }

  type t = data
  let json_of_t = json_of_data
  let t_of_json = data_of_json

end

include T
include Fmt.Extend(T)

let default mustpay = {
  grant     = None ;
  admin_act = false ;
  user_act  = false ;
  time      = 0.0 ;
  status    = `NotMember ;
  mustpay   = mustpay 
}

let reflect id data =
  
  let mustpay = false in (* No payment management yet *)
  
  let! group_opt = ohm $ MGroup.naked_get data.Details.where in

  let! manual = ohm begin 
    let! group = req_or (return true) group_opt in 
    return $ MGroup.Get.manual group 
  end in

  let status = Details.status ~manual data in 
  
  let! grant = ohm begin
    
    (* Only evaluate token-granting for actual members *)
    if status = `Member then begin
      
      let grant = match group_opt with None -> None | Some group ->
	match MGroup.Token.get group with 
	  | `token   -> Some `Token
	  | `contact -> None
	  | `admin   -> Some `Admin
      in
      
      return grant
	
    end else return None  
  end in
  
  let admin_act = match status with 
    | `Pending -> true
    | `Unpaid
    | `Invited
    | `NotMember
    | `Declined
    | `Member -> false
  in
  
  let user_act  = match status with 
    | `Unpaid
    | `Invited -> true
    | `Pending
    | `NotMember
    | `Declined
    | `Member -> false
  in
  
  let time = Details.last data in
  
  return {
    status ;
    grant ;
    admin_act ;
    user_act ;
    time ;
    mustpay
  }
