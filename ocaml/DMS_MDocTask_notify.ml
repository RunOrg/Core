(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Core = DMS_MDocTask_core

include MMail.Register(struct

  include Fmt.Make(struct
    type json t = <
      role : [ `Assigned "a" | `Notified "n" ] ;
      what : [ `NewState    of Json.t 
	     | `SetAssigned of IAvatar.t option (* None if self *) 
	     | `SetNotified ] ;
      uid  : IUser.t ;
      iid  : IInstance.t ;
      dtid : DMS_IDocTask.t ;
      did  : DMS_IDocument.t ; 
      from : IAvatar.t ;
    >
  end)
   
  let id = IMail.Plugin.of_string "dms-doctask"
  let iid x = Some (x # iid)
  let uid x = x # uid
  let from x = Some (x # from) 
  let solve _ = None
  let item _ = true

end)

(* React to new versions in the async process to avoid overloading 
   the web server with version queries. *)
let task = O.async # define "dms-doctask-notify" Core.Store.VersionId.fmt begin fun vid ->
  return () 
end

let () = 
  let! version = Sig.listen Core.Store.Signals.version_create in
  let  id = Core.Store.version_id version in 
  task id 
