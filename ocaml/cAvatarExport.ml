(* © 2012 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Export = MCsvExport

module Render = CAvatarExport_render

module TaskFmt = Fmt.Make(struct
  type json t = (IAvatar.t option * IExport.t * IAvatarSet.t * (MAvatarGridEval.t list))
end)

let cells_by_step = 50

let task,define = O.async # declare "avatar-export" TaskFmt.fmt 
let () = define begin fun (start,exid,gid,evals) ->

  let  count = max 1 (cells_by_step / List.length evals) in 

  (* Acting as bot to list group contents. *)
  let  bgid  = IAvatarSet.Assert.bot gid in  
  let! aids, next = ohm $ MMembership.InGroup.avatars bgid ~start ~count in
  
  (* A function that processes one cell. *)
  let cell aid eval = 
    let! json, _ = ohm $ MAvatarGrid.Config.apply aid eval in 
    Render.cell json eval 
  in

  (* Process all cells. *)
  let! lines = ohm $ Run.list_map (fun aid -> Run.list_map (cell aid) evals) aids in

  (* Save them to the export *)
  let! () = ohm $ Export.add exid lines in

  if next = None then 
    MCsvExport.finish exid
  else
    task (next,exid,gid,evals) 
end

let start gid =   
  let! size = ohm (Run.map (#any) (MMembership.InGroup.count gid)) in
  let! names, evals = ohm begin

    (* Grab all the columns for export, replacing the "full" column with 
       firstname, lastname and email for better rendering. *)

    let! group = ohm_req_or (return ([],[])) $ MGroup.naked_get gid in
    let  lid = MGroup.Get.list group in 
    let! columns, _, _ = ohm_req_or (return ([],[])) $ MAvatarGrid.MyGrid.get_list 
      (MAvatarGrid.list_id lid) in 
    let  from_columns = List.concat (List.map (fun column -> 
      match column.MAvatarGridColumn.eval with 
	| `Profile (iid,`Full) -> 
	  [ `label `ColumnUserBasicFirstname, `Profile (iid,`Firstname) ;
	    `label `ColumnUserBasicLastname,  `Profile (iid,`Lastname) ;
	    `label `ColumnUserBasicEmail,     `Profile (iid,`Email) ]
	| eval -> [ column.MAvatarGridColumn.label, eval ]
    ) columns) in

    (* Grab all the *local* group fields and turn them into columns as well
       (but avoid duplicate columns) *)
    
    let! fields = ohm $ MGroup.Fields.local gid in 
    let  from_fields = BatList.filter_map (fun field -> 
      let eval = `Group (IAvatarSet.decay gid, `Field (field # name)) in
      if List.exists (snd |- (=) eval) from_columns then None else
	Some (field # label, eval)
    ) fields in 

    (* Split the list into names and evaluators *)
    let list = from_columns @ from_fields in
    
    return (List.split list) 

  end in 

  let! heading = ohm $ Run.list_map TextOrAdlib.to_string names in 

  let! exid = ohm $ Export.create ~size ~heading () in

  let! () = ohm $ task (None,IExport.decay exid,IAvatarSet.decay gid, evals) in

  return exid
