(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Tbl = MAvatar_common.Tbl

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

let using aid f = Tbl.using (IAvatar.decay aid) f

let get_user aid = using aid (#who) 
let get_instance aid = using aid (#ins)

let details aid = 
  Tbl.get (IAvatar.decay aid) |> Run.map begin function
    | None      -> no_details
    | Some data -> from data
  end 
