(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module StatusEditFmt = Fmt.Make(struct
  type json t = <
    invite : bool option ;
    user   : bool option ;
    admin  : bool option 
  >
end)

module Top = CJoin_top 
module Self = CJoin_self

let template group = 
  List.fold_left (fun acc field -> 
    acc |> OhmForm.append (fun json result -> return $ (field # name,result) :: json)
	begin match field # edit with 
	  | `Checkbox
	  | `Date
	  | `LongText
	  | `PickMany _ 
	  | `PickOne  _ 
	  | `Textarea ->
	    (VEliteForm.textarea 
	       ~label:(TextOrAdlib.to_string (field # label))
	       (fun data -> return begin 
		 try Json.to_string (List.assoc (field # name) data)
		 with _ -> ""
	       end)
	       (OhmForm.keep)) 
	end 
  ) (OhmForm.begin_object []) (MGroup.Fields.get group)

  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Join_Edit_Save)


let status_edit aid mid access kind group profile = fun edit _ self res ->

  let diffs = 
    (   match edit # invite with Some _ -> [ `Invite    ] | None -> [] ) 
    @ ( match edit # admin  with Some b -> [ `Accept  b ] | None -> [] )
    @ ( match edit # user   with Some b -> [ `Default b ] | None -> [] ) 
  in
  
  let gid = MGroup.Get.id group in 

  let! () = ohm $ O.decay (MMembership.admin ~from:(access # self) gid aid diffs) in
  
  let! mbr = ohm $ O.decay (MMembership.get mid) in 
  let  mbr = BatOption.default 
    (MMembership.default ~mustpay:false ~group:(IGroup.decay gid) ~avatar:aid) mbr in

  let! html = ohm $ Top.render kind profile mbr.MMembership.status self in   
  return $ Action.json [ "top", Html.to_json html ] res

let box entity access fail wrapper = 

  let! aid = O.Box.parse IAvatar.seg in 

  let  draft  = MEntity.Get.draft entity in 

  let  kind = MEntity.Get.kind entity in 

  let  gid = MEntity.Get.group entity in
  let! group = ohm $ O.decay (MGroup.try_get access gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.write group) in
  let  group = if draft then None else group in   
  let! group = req_or fail group in 

  let! profile = ohm $ O.decay (CAvatar.mini_profile aid) in

  let! mid = ohm $ O.decay (MMembership.as_admin (MGroup.Get.id group) aid) in 

  let! status_edit = O.Box.react StatusEditFmt.fmt (status_edit aid mid access kind group profile) in

  let! data_edit = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 
    return res
  end in

  O.Box.fill begin 

    let! mbr = ohm $ O.decay (MMembership.get mid) in 
    let  mbr = BatOption.default (MMembership.default ~mustpay:false ~group:gid ~avatar:aid) mbr in
    
    let fields = if MGroup.Fields.get group = [] then None else Some begin

      let! data = ohm $ O.decay (MMembership.Data.get mid) in

      let template = template group in 
      let form = OhmForm.create ~template ~source:(OhmForm.from_seed data) in
      let url  = OhmBox.reaction_endpoint data_edit () in

      Asset_EliteForm_Form.render (OhmForm.render form url)

    end in 

    let body = Asset_Join_Edit.render (object
      method top  = Top.render kind profile mbr.MMembership.status status_edit
      method form = fields
    end) in

    wrapper (profile # name) body 

  end
