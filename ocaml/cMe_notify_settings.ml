(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module DefaultFmt = Fmt.Make(struct
  type json t = [ `Everything | `Relevant | `Nothing ]
end)

module InstanceFmt = Fmt.Make(struct
  type json t = [ `Default | `Everything | `Relevant | `Nothing ]
end)

let template instances = 
  
  OhmForm.begin_object (fun ~default ~instances -> (object
    method default = default
    method instances = instances
  end)) 

  |> OhmForm.append (fun f default -> return $ f ~default) 
      (VNotify.default
	 ~format:DefaultFmt.fmt
	 ~source:(List.map (fun stat -> stat, Asset_Notify_DefaultSetting.render (object
	   method choice = AdLib.write (`Notify_Settings_Choice (stat :> InstanceFmt.t))
	   method detail = AdLib.write (`Notify_Settings_Detail stat)
	 end))
		    [ `Everything ; `Relevant ; `Nothing ])
	 (fun _ -> return $ Some `Everything)
	 OhmForm.keep) 
      
  |> OhmForm.append (fun f instances -> return $ f ~instances) 
      (List.fold_left
	 (fun fields instance -> 
	   OhmForm.append (fun list choice -> return ((instance # iid,choice) :: list)) 
	     (VNotify.radio 
		~name:(instance # name)
		~pic:(instance # pic) 
		~format:InstanceFmt.fmt
		~source:(List.map 
			   (fun stat -> stat, AdLib.write (`Notify_Settings_Choice stat))
			   [ `Default ; `Everything ; `Relevant ; `Nothing ])
		(fun _ -> return $ Some `Default) 
		OhmForm.keep)
	     fields)
	 (OhmForm.begin_object []) instances
      )

  |> OhmForm.Skin.with_ok_button ~ok:(AdLib.get `Notify_Settings_Submit) 

let () = define UrlMe.Notify.def_settings begin fun cuid -> 

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
	method iid  = iid
      end)
    ) (admin_of @ member_of) 

  end in 

  let template = template instances in 

  let! save = O.Box.react Fmt.Unit.fmt begin fun () json _ res -> 
    return res
  end in
  
  O.Box.fill begin

    let form = OhmForm.create ~template ~source:(OhmForm.empty) in
    let url  = OhmBox.reaction_endpoint save () in
    
    Asset_Admin_Page.render (object
      method parents = [ object
	method title = AdLib.get `Notify_Title
	method url   = Action.url UrlMe.Notify.home () () 
      end ]
      method here  = AdLib.get `Notify_Settings_Title
      method body  = Asset_Notify_Settings.render (OhmForm.render form url)
    end)

  end
end
