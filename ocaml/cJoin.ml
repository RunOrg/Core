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
module Public = CJoin_public

let template fields = 
  List.fold_left (fun acc field -> 
    acc |> OhmForm.append (fun json result -> return $ (field # name,result) :: json)
	begin let json seed = List.assoc (field # name) seed in 
	      let label = TextOrAdlib.to_string (field # label) in 
	      match field # edit with 
		| `Checkbox ->
		  (VEliteForm.checkboxes ~label
		     ~format:Fmt.Unit.fmt
		     ~source:[ (), return ignore ]
		     (fun seed -> return (try if Json.to_bool (json seed) then [()] else [] 
		                          with _ -> []))
		     (fun field data -> return $ Ok (Json.Bool (data <> []))))
		| `Date ->
		  (VEliteForm.date ~label
		     (fun seed -> return (try Json.to_string (json seed) with _ -> ""))
		     (fun field data -> return $ Ok (Json.String data)))
		| `LongText -> 
		  (VEliteForm.text ~label
		     (fun seed -> return (try Json.to_string (json seed) with _ -> ""))
		     (fun field data -> return $ Ok (Json.String data))) 
		| `PickOne list -> 
		  (VEliteForm.radio ~label
		     ~format:Fmt.Int.fmt
		     ~source:(BatList.mapi (fun i label -> i, TextOrAdlib.to_html label) list)
		     (fun seed -> return (try Some (Json.to_int (json seed)) with _ -> None))
		     (fun field data -> return $ Ok (Json.of_opt Json.of_int data)))
		| `PickMany list ->
		  (VEliteForm.checkboxes ~label
		     ~format:Fmt.Int.fmt
		     ~source:(BatList.mapi (fun i label -> i, TextOrAdlib.to_html label) list)
		     (fun seed -> return (try Json.to_list Json.to_int (json seed) with _ -> []))
		     (fun field data -> return $ Ok (Json.of_list Json.of_int data)))
		| `Textarea ->
		  (VEliteForm.textarea ~label
		     (fun data -> return (try Json.to_string (json data) with _ -> ""))
		     (fun field data -> return $ Ok (Json.String data))) 
	end 
  ) (OhmForm.begin_object []) fields

  |> VEliteForm.with_ok_button ~ok:(AdLib.get `Join_Edit_Save)


let status_edit aid mid access kind group profile = fun edit _ self res ->

  let diffs = 
    (   match edit # invite with Some _ -> [ `Invite    ] | None -> [] ) 
    @ ( match edit # admin  with Some b -> [ `Accept  b ] | None -> [] )
    @ ( match edit # user   with Some b -> [ `Default b ] | None -> [] ) 
  in
  
  let  gid = MGroup.Get.id group in 

  let! () = ohm $ O.decay (MMembership.admin ~from:(access # self) gid aid diffs) in
  
  let! mbr = ohm $ O.decay (MMembership.get mid) in 
  let  mbr = BatOption.default 
    (MMembership.default ~mustpay:false ~group:(IGroup.decay gid) ~avatar:aid) mbr in

  let! html = ohm $ Top.render kind profile mbr.MMembership.status self in   
  return $ Action.json [ "top", Html.to_json html ] res

let box kind gid access fail wrapper = 

  let  actor = access # actor in 
  let! aid = O.Box.parse IAvatar.seg in 

  let! group = ohm $ O.decay (MGroup.try_get actor gid) in
  let! group = ohm $ O.decay (Run.opt_bind MGroup.Can.write group) in
  let! group = req_or fail group in 

  let! profile = ohm $ O.decay (CAvatar.mini_profile aid) in

  let! mid = ohm $ O.decay (MMembership.as_admin (MGroup.Get.id group) aid) in 

  let! status_edit = O.Box.react StatusEditFmt.fmt 
    (status_edit aid mid access kind group profile)
  in

  let! data_edit = O.Box.react Fmt.Unit.fmt begin fun _ json _ res -> 

    let! fields = ohm $ O.decay (MGroup.Fields.local gid) in 
    let  template = template fields in
    let  src = OhmForm.from_post_json json in 
    
    let  form = OhmForm.create ~template ~source:src in
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  
    
    (* Save the data and process the join request *)
    
    let info = MUpdateInfo.info ~who:(`user (Id.gen (), IAvatar.decay (access # self))) in

    let! () = ohm $ O.decay (MMembership.Data.admin_update 
			       (access # self) (MGroup.Get.id group) aid info result)
    in

    return res

  end in

  O.Box.fill begin 

    let! fields = ohm $ O.decay (MGroup.Fields.local gid) in 

    let! mbr = ohm $ O.decay (MMembership.get mid) in 
    let  mbr = BatOption.default 
      (MMembership.default ~mustpay:false ~group:gid ~avatar:aid) mbr
    in
    
    let fields = if fields = [] then None else Some begin

      let! data = ohm $ O.decay (MMembership.Data.get mid) in

      let template = template fields in 
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
