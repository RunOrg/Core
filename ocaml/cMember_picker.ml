(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let configure iid ~(ctx:'any CContext.full) component = 
  let url = 
    let instance = ctx # instance in
    let user     = IIsIn.user (ctx # myself) in
    UrlMember.autocomplete_joy # build instance iid user
  in
  component
    ~format:IAvatar.fmt
    ~source:(`Dynamic url)

let () = CClient.User.register CClient.is_contact UrlMember.autocomplete_joy 
  begin fun ctx request response ->
    
    let i18n  = ctx # i18n in
    let respond list = return
      (Action.json (Joy.select_return_list IAvatar.fmt i18n list) response)
    in
    let panic = respond [] in
    
    (* Determine whether we can see *)

    let! proof = req_or panic (request # args 0) in
    let inst  = IIsIn.instance (ctx # myself) in
    let user  = IIsIn.user     (ctx # myself) in 
    
    let! see = req_or panic
      (IInstance.Deduce.from_seeContacts_token inst user proof) 
    in
    
    (* We can see, let's handle the request *)

    let extract (id,_,details) = 
      let status  = ctx # status (match details # status with Some x -> x | None -> `Contact) in
      let name    = CName.get i18n details in 
      
      let! pic = ohm (ctx # picture_small (details # picture)) in
      
      let html, _ = View.extract (VMember.AutocompleteJoy.item ~name ~status ~pic ~i18n) in
      
      return (id, `text name, Some (fun _ -> View.str html))
    in

    match Joy.select_search_param IAvatar.fmt request with 
      | `Complete term ->

	let count = 4 in 
    	let! list = ohm (MAvatar.search see term count) in      
        let! result = ohm (Run.list_map extract list) in
	respond result

      | `Get id ->
	
	let! details = ohm (MAvatar.details id) in
	let! result = ohm (extract (id,"",details)) in
	respond [result]
	  
  end 
  
