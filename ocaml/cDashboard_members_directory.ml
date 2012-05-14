(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives
open O

open CDashboard_common

let async ~ctx ~(iid: [`ViewContacts] IInstance.id) = 
  O.Box.reaction "directory" begin fun self bctx req res ->

    let count = 27 in

    let! members = ohm (MAvatar.List.with_pictures ~count iid) in

    let members = 
      if List.length members < 27 then BatList.take 13 members
      else members
    in

    let! avatars = ohm (CAvatar.extract (ctx # i18n) ctx members) in

    let! usage   = ohm (MAvatar.usage iid) in 

    let prefix, _ = bctx # args in

    let data = object
      method members = usage 
      method url     = UrlR.build (ctx # instance) (bctx # segments) (prefix,`Directory)
      method avatars = List.map (fun a -> (object
	method name = a # name
	method url  = a # url
	method pic  = a # picture
      end)) avatars
    end in

    return (Action.json
	      (Js.Html.return 
		 (VDashboard.Directory.render data (ctx # i18n)))
	      res)

  end

let block ~ctx = 

  let! view_directory = ohm $ MInstanceAccess.can_view_directory ctx in

  match view_directory with 
    | None -> return (callback_return None)
    | Some iid -> 

      let! access = ohm $ MInstanceAccess.view_directory iid in 
      
      let! granting = ohm $ MEntity.All.get_administrable_granting ctx in
      let  green = if granting = [] then None else Some (`url (
	UrlR.build (ctx # instance) O.Box.Seg.(root ++ UrlSegs.root_pages)
	  ((),`AddMembers)))
      in
      
      return (fun callback -> 
	let! directory = async ~ctx ~iid in
	callback (Some (fun bctx (prefix,_) ->
	  element
	    ~icon:VIcon.group
	    ~url:(UrlR.build (ctx # instance) (bctx # segments) (prefix,`Directory))
	    ~base:"directory"
	    ~load:(Some (bctx # reaction_url directory))
	    ~green
	    ~access
	    ~hasdesc:false
	))
      )  
