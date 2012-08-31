(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Export = MCsvExport

module TaskFmt = Fmt.Make(struct
  type json t = (IAvatar.t option * IExport.t * IGroup.t * (MAvatarGridEval.t list))
end)

let task,define = O.async # declare "avatar-export" TaskFmt.fmt 
let () = define begin fun (aid_opt,exid,gid,evals) ->
  return () 
end

let start gid =   
  let! size = ohm (Run.map (#any) (MMembership.InGroup.count gid)) in
  let! exid = ohm $ Export.create ~size () in
  return exid
