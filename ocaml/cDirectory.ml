(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let list_count = 24 (* Can be divided by 2, 3, 4, 6 *)

(* The home page itself --------------------------------------------------------------------- *)

module Home = struct

  let form iid ctx = 

    Joy.begin_object (fun ~who -> who)
      
    |> Joy.append (fun f who -> f ~who) 
	(CMember.Picker.configure iid ~ctx 
	   (fun ~format ~source ->
	     Joy.select ~field:"input" ~format ~source
	       (fun _ init -> None)
	       (fun _ field value -> Ok value))
	)

    |> Joy.end_object
	~html:("",VDirectory.FullPageSearch.render ())

  module Pager = CPaging.More(struct
    module Key = Ohm.Fmt.String
    type data = IAvatar.t
  end)
    
  let search iid ctx = 
    O.Box.reaction "search" begin fun self bctx req res ->
      let form = Joy.create (form iid ctx) (ctx # i18n) (Joy.from_post_json (bctx # json)) in
      match Joy.result form with Bad _ -> return res | Ok aidopt ->
	match aidopt with None -> return res | Some aid -> 
	  let (++) = Box.Seg.(++) in
	  let segs = Box.Seg.root ++ CSegs.root_pages ++ CSegs.avatar_id in
	  let data = ((),`Profile), Some aid in
	  return (Action.javascript 
		    (Js.redirect (UrlR.build (ctx # instance) segs data))
		    res)
    end

  class ['a,'b] source iid ctx search = object (self)

    val iid = iid
    val ctx = ( ctx : 'a CContext.full )
    val search = search 
      
    method list start = 
      MAvatar.list_members ?start ~count:list_count iid
	
    method render view more (list : IAvatar.t list) = 
      let! list   = ohm $ CAvatar.extract (ctx # i18n) ctx list in
      let! access = ohm $ MInstanceAccess.view_directory iid  in
      return (view ~more ~list ~access ~i18n:(ctx # i18n))

    method more ~(bctx:'b) ~more ~list = 
      self # render (fun ~more ~list ~access ~i18n ->
	VDirectory.more ~more ~list ~i18n
      ) more list

    method page ~(bctx:'b) ~more ~list = 
      self # render (fun ~more ~list ~access ~i18n ->
	let form = Joy.create (form iid ctx) i18n Joy.empty in
	let search = bctx # reaction_url search in
	VDirectory.FullPage.render (object
	  method more   = more
	  method list   = list
	  method access = Some (`Page access) 
	  method search i18n vctx = Joy.render form search vctx 
	end) i18n) more list
	
  end
    
end
  
let home_box ~iid ~ctx =
  let! search = Home.search iid ctx in
  Home.Pager.box (new Home.source iid ctx search)

(* The admins directory --------------------------------------------------------------------- *)

module Admins = struct

  module Pager = CPaging.More(struct
    module Key = Ohm.Fmt.String
    type data = IAvatar.t
  end)
    
  class ['a,'b] source iid ctx = object (self)

    val iid = iid
    val ctx = ( ctx : 'a CContext.full )
      
    method list start = 
      MAvatar.list_administrators ?start ~count:list_count iid
	
    method render view more (list : IAvatar.t list) = 
      let! list   = ohm $ CAvatar.extract (ctx # i18n) ctx list in
      return (view ~more ~list ~i18n:(ctx # i18n))

    method more ~(bctx:'b) ~more ~list = 
      self # render (fun ~more ~list ~i18n ->
	VDirectory.more ~more ~list ~i18n
      ) more list

    method page ~(bctx:'b) ~more ~list = 

      let  pcnamer = MPreConfigNamer.load iid in 
      let! eid     = ohm $ MPreConfigNamer.entity "admin" pcnamer in
      let group = 
	UrlR.build (ctx # instance) 
	  O.Box.Seg.(root ++ UrlSegs.root_pages ++ UrlSegs.entity_id ++ UrlSegs.entity_tabs) 
	  ((((),`Entity),Some eid),`Admin_People)
      and add = 
	UrlR.build (ctx # instance) 
	  O.Box.Seg.(UrlSegs.(root ++ root_pages ++ entity_id ++ add_tabs `Import)) 
	  ((((),`AddMembers),Some eid),`Import)
      in

      self # render (fun ~more ~list ~i18n ->
	VDirectory.AdminPage.render (object
	  method more   = more
	  method list   = list
	  method group  = group 
	  method add    = add
	end) i18n) more list
	
  end
    
end
  
let admins_box ~ctx =
  let iid = IIsIn.instance (ctx # myself) in 
  Admins.Pager.box (new Admins.source iid ctx)

(* Displaying participants inside an entity ---------------------------------------------- *)

module CEntity = struct

  module Pager = CPaging.More(struct
    module Key = Id
    type data = IAvatar.t
  end)

  class ['a,'b] source gid ctx = object (self)
    val gid = gid
    val ctx = ( ctx : 'a CContext.full )

    method list start =
      MMembership.InGroup.list_members ?start ~count:list_count gid
	
    method render view more (list : IAvatar.t list) = 
      let! list = ohm (CAvatar.extract (ctx # i18n) ctx list) in
      return (view ~more ~list ~i18n:(ctx # i18n))

    method more ~(bctx:'b) ~more ~list = 
      self # render VDirectory.more more list

    method page ~(bctx:'b) ~more ~list = 
      self # render VDirectory.page more list

  end

end

let entity_box ~gid ~ctx = 
  CEntity.Pager.box (new CEntity.source gid ctx)
