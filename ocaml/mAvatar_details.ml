(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module MyTable = MAvatar_common.MyTable

type details = <
  name    : string option ;
  sort    : string option ;
  picture : [`GetPic] IFile.id option ;
  who     : IUser.t option ;
  ins     : IInstance.t option ;
  status  : MAvatar_status.t option ;
  role    : string option ;
> ;;

let no_details = object 
  method name    = None 
  method sort    = None
  method picture = None 
  method who     = None
  method ins     = None
  method role    = None
  method status  = None
end 
  
let from data = object
  method who     = Some (data # who)
  method ins     = Some (data # ins)
  method name    = data # name
  method sort    = Util.first (data # sort)
  method picture = BatOption.map IFile.Assert.get_pic data # picture (* Can view avatar *)
  method role    = data # role
  method status  = Some (data # sta)
end 

let get_user aid = 
  let! avatar = ohm_req_or (return None) $ MyTable.get (IAvatar.decay aid) in
  return $ Some (avatar # who) 

let details id = 
  MyTable.get (IAvatar.decay id) |> Run.map begin function
    | None      -> no_details
    | Some data -> from data
  end 
