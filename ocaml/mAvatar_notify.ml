(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal

module Plugin = struct

  include Fmt.Make(struct 
    type json t = 
      [ `UpgradeToAdmin  of IUser.t * IInstance.t * IAvatar.t
      | `UpgradeToMember of IUser.t * IInstance.t * IAvatar.t
      ]
  end) 

  let id = IMail.Plugin.of_string "avatar"

  let iid = function 
    | `UpgradeToAdmin (_,iid,_) | `UpgradeToMember (_,iid,_) -> Some iid

  let uid = function 
    | `UpgradeToAdmin (uid,_,_) | `UpgradeToMember (uid,_,_) -> uid

  let from = function 
    | `UpgradeToAdmin (_,_,aid) | `UpgradeToMember (_,_,aid) -> Some aid 

  let solve _ = None

end 

include MMail.Register(Plugin) 

let upgrade_to_admin ~uid ~iid ~from = 
  send_one (`UpgradeToAdmin (uid, iid, from)) 

let upgrade_to_member ~uid ~iid ~from = 
  send_one (`UpgradeToMember (uid, iid, from)) 
