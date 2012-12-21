(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module DefaultFmt = Fmt.Make(struct
  type json t = [ `Everything | `Relevant | `Nothing ]
end)


let never = List.map (fun chan -> chan, `Never) 
  [ `NewWallItem `WallReader ;
    `NewWallItem `WallAdmin ;
    `NewComment `ItemAuthor ;
    `NewComment `ItemFollower ;
    `BecomeMember ;
    `EventInvite ;
    `EntityRequest ;
    `Broadcast ]

let default_of_assoc assoc = 
  let get chan = try List.assoc chan assoc with Not_found -> MNotify.ToUser.default chan in 
  if get (`NewWallItem `WallReader) = `Immediate then
    `Everything
  else if get `EventInvite = `Immediate then
    `Relevant
  else
    `Nothing	      

let assoc_of_default = function
  | `Everything -> []
  | `Relevant -> [ `NewWallItem `WallReader, `Daily ;
		   `NewWallItem `WallAdmin, `Daily ;
		   `NewFavorite `ItemAuthor, `Weekly ;
		   `NewComment `ItemFollower, `Weekly ;
		   `EntityRequest, `Weekly ;
		   `Broadcast, `Weekly ]
  | `Nothing -> never

module InstanceFmt = Fmt.Make(struct
  type json t = [ `Default | `Everything | `Relevant | `Nothing ]
end)


let instance_of_assoc assoc = 
  List.map (fun (iid, freq) -> iid, (default_of_assoc (List.assoc iid assoc) :> InstanceFmt.t))
    assoc

let assoc_of_instance = function 
  | `Default -> None
  | #DefaultFmt.t as d -> Some (assoc_of_default d)

let template instances = 
  
  OhmForm.begin_object (fun ~default ~instances -> (object
    method default = assoc_of_default (BatOption.default `Everything default) 
    method by_iid  = BatList.filter_map (fun (iid, x) -> match assoc_of_instance x with 
      | None -> None
      | Some freq -> Some (iid, freq)) instances
  end)) 

  |> OhmForm.append (fun f default -> return $ f ~default) 
      (VNotify.default
	 ~format:DefaultFmt.fmt
	 ~source:(List.map (fun stat -> stat, Asset_Notify_DefaultSetting.render (object
	   method choice = AdLib.write (`Notify_Settings_Choice (stat :> InstanceFmt.t))
	   method detail = AdLib.write (`Notify_Settings_Detail stat)
	 end))
		    [ `Everything ; `Relevant ; `Nothing ])
	 (fun (d,_) -> return $ Some d)
	 OhmForm.keep) 
      
  |> OhmForm.append (fun f instances -> return $ f ~instances) 
      (List.fold_left
	 (fun fields instance -> 
	   OhmForm.append 
	     (fun list choice -> 
	       return ((instance # iid,BatOption.default `Default choice) :: list)) 
	     (VNotify.radio 
		~name:(instance # name)
		~pic:(instance # pic) 
		~format:InstanceFmt.fmt
		~source:(List.map 
			   (fun stat -> stat, AdLib.write (`Notify_Settings_Choice stat))
			   [ `Default ; `Everything ; `Relevant ; `Nothing ])
		(fun (_,l) -> return $ Some 
		  (try List.assoc (instance # iid) l with Not_found -> `Default)) 
		OhmForm.keep)
	     fields)
	 (OhmForm.begin_object []) instances
      )

  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Notify_Settings_Submit) 

let () = define UrlMe.Notify.def_settings begin fun owid cuid -> 

  let! instances = ohm $ O.decay begin

    let max_items = 150 in
    
    let  uid = IUser.Deduce.can_view_inst cuid in
    let  count     = max_items in
    let! admin_of  = ohm $ MAvatar.user_instances ~count ~status:`Admin uid in
    let  count     = max_items - List.length admin_of in
    let! member_of = ohm $ MAvatar.user_instances ~count ~status:`Token uid in

    Run.list_filter (fun (_,iid) ->
      let! instance = ohm_req_or (return None) $ MInstance.get iid in 
      let! pic = ohm $ CPicture.small_opt (instance # pic) in
      return $ Some (object
	method name = instance # name
	method pic  = pic
	method iid  = IInstance.decay iid
      end)
    ) (admin_of @ member_of) 

  end in 

  let template = template instances in 

  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 

    let uid = IUser.Deduce.can_edit cuid in

    let source = OhmForm.from_post_json json in 
    let form = OhmForm.create ~template ~source in
        
    (* Extract the result for the form *)
    
    let fail errors = 
      let  form = OhmForm.set_errors errors form in
      let! json = ohm $ OhmForm.response form in
      return $ Action.json json res
    in
    
    let! result = ohm_ok_or fail $ OhmForm.result form in  

    (* Save the changes to the database *)

    let! () = ohm $ O.decay (MNotify.ToUser.set uid result) in
    
    (* Redirect to main page *)

    let url = Action.url UrlMe.Notify.home owid () in 
    return $ Action.javascript (Js.redirect url ()) res


  end in
  
  O.Box.fill begin

    let! source = ohm $ O.decay begin 

      let  uid  = IUser.Deduce.can_edit cuid in
      let! freq = ohm $ MNotify.ToUser.get uid in 
      
      return $ OhmForm.from_seed 
	(default_of_assoc (freq # default), 
	 instance_of_assoc (freq # by_iid))
      
    end in 

    let form = OhmForm.create ~template ~source in 
    let url  = OhmBox.reaction_endpoint save () in
    
    Asset_Admin_Page.render (object
      method parents = [ object
	method title = AdLib.get `Notify_Title
	method url   = Action.url UrlMe.Notify.home owid () 
      end ]
      method here  = AdLib.get `Notify_Settings_Title
      method body  = Asset_Notify_Settings.render (OhmForm.render form url)
    end)

  end
end
