(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives
open O

module Accessor = Fmt.Make(struct
  type json t = [ `Avatar "a" of IAvatar.t | `Group "g" of IGroup.t ]
end)

type access = 
    {
      avatars : IAvatar.t list ;
      groups  : IGroup.t list ;
    }

let field ~ctx =  

  let missing = return (fun ~label ?minitip seed -> Joy.constant None) in

  let! iid = ohm_req_or missing (MInstanceAccess.can_view_directory ctx) in

  let dynamic = 
    let instance = ctx # instance in
    let user     = IIsIn.user (ctx # myself) in
    UrlAccess.autocomplete # build instance iid user
  in

  let! entities = ohm (MEntity.All.get_with_members ctx) in

  let extract e = 

    let id = MEntity.Get.group e in 
    
    let name   = CName.of_entity e in      
    let kind   = MEntity.Get.kind e in
    
    let! pic = ohm (ctx # picture_small (MEntity.Get.picture e)) in
    
    return (Some (`Group id, name, Some (fun i18n ->
      let html, _ = View.extract (VAccess.Autocomplete.render (object
	method name = name
	method kind = kind
	method pic  = pic 
      end) i18n) in  View.str html
    )))
  in

  let! static = ohm (Run.list_filter extract entities) in

  let select = 
    VQuickForm.mini_select
      ~format:Accessor.fmt 
      ~source:(`Both (static,dynamic))
      (fun _ init -> Some init) 
      (fun _ _ value -> Ok value)
  in

  let array ~label ~minitip = 
    VQuickForm.fieldArray 
      ~add:(`label "access.list.add") 
      ~label 
      ?minitip
      select
  in
  
  return (fun ~label ?minitip seed ->

    array ~label ~minitip
    |> Joy.seed_map (fun data ->
      let access = seed data in
      List.map (fun a -> `Avatar a) access.avatars @ List.map (fun g -> `Group g) access.groups)
    |> Joy.result_map (fun list ->
      Some ({
	avatars = BatList.filter_map (function Some (`Avatar a) -> Some a | _ -> None) list ;
	groups  = BatList.filter_map (function Some (`Group  g) -> Some g | _ -> None) list
      }))
  )

let extract access = 
  let empty = { groups = [] ; avatars = [] } in
  let rec aux = function
    | `List l -> { groups = [] ; avatars = l }
    | `Groups (`Validated,l) -> { groups = l ; avatars = [] }
    | `Union l -> let l = List.map aux l in 
		  { groups = List.concat (List.map (fun x -> x.groups) l) ;
		    avatars = List.concat (List.map (fun x -> x.avatars) l) }
    | _  -> empty
  in
  let found = aux access in 
  { groups  = BatList.sort_unique compare found.groups ;
    avatars = BatList.sort_unique compare found.avatars }

let apply access g = 

  let rec clean : MAccess.t -> MAccess.t option = function 
    | `Groups (`Validated,_) -> None
    | `List _ -> None
    | `Union l -> let l = BatList.filter_map clean l in
		  (match l with 
		    | [] -> None
		    | [x] -> Some x
		    | l -> Some (`Union l))
    | other -> Some other
  in

  let groups  = `Groups (`Validated,g.groups) in
  let avatars = `List g.avatars in
  
  `Union [ groups ; avatars ; BatOption.default `Nobody (clean access) ]
  

let () = CClient.User.register CClient.is_contact UrlAccess.autocomplete
  begin fun ctx request response ->
    
    let i18n  = ctx # i18n in
    let respond list = return (Action.json (Joy.select_return_list Accessor.fmt i18n list) response) in
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
      
      return (`Avatar id, `text name, Some (fun _ -> View.str html))
    in

    match Joy.select_search_param Accessor.fmt request with 
      | `Complete term ->

	let count = 4 in 
    	let! list = ohm (MAvatar.search see term count) in      
        let! result = ohm (Run.list_map extract list) in
	respond result

      | `Get (`Avatar id) ->
	
	let! details = ohm (MAvatar.details id) in
	let! result = ohm (extract (id,"",details)) in
	respond [result]

      | `Get _ -> panic
	  
  end 

  
