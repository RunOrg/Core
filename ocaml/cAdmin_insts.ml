(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CAdmin_common

module Parents = CAdmin_parents

let more, def_more = O.declare O.secure "admin/insts/more" Action.Args.(o float)

let more t = VMore.li (JsCode.Endpoint.of_url (Action.url more None t), Json.Null)

let () = def_more $ admin_only begin fun cuid req res ->
  let! list, next = ohm (MInstance.Backdoor.chrono cuid ~count:5 (req # args)) in
  let  more = BatOption.map (fun time -> more (Some time)) next in 
  let! now  = ohmctx (#time) in
  let! list = ohm (Run.list_map begin fun (iid, i) -> 
    let! pic = ohm (CPicture.small_opt (i # pic)) in
    let! members = ohm (MAvatar.Backdoor.instance_member_count cuid iid) in
    let! admins = ohm (MAvatar.Backdoor.instance_admins cuid iid) in
    let! admins = ohm (Run.list_filter begin fun details -> 
      let! pic  = ohm (CPicture.small_opt (details # picture)) in 
      let! uid  = req_or (return None) (details # who) in
      let! user = ohm_req_or (return None) (MUser.Backdoor.get cuid uid) in
      return (Some (object
	method email = user # email
	method pic   = pic
	method name  = user # fullname
	method phone = match user # cellphone with Some p -> Some p | None -> user # phone
      end))
    end admins) in 
    return (object
      method name    = i # name
      method pic     = pic 
      method date    = (i # create, now) 
      method url     = Action.url UrlClient.website (i # key) ()	
      method admins  = admins
      method members = members
    end)
  end  list) in 
  let! html = ohm (Asset_Admin_Instances.render (object
    method list = list
    method more = more
  end)) in
  return (Action.json [ "more" , Html.to_json html ] res)  
end


let () = UrlAdmin.def_insts $ admin_only begin fun cuid req res -> 

  page cuid "Administration" (object
    method parents = [ Parents.home ] 
    method here  = Parents.insts # title 
    method body  = let! more = ohm (more None) in
		   return Html.(concat [ str "<ul class='admin-list'>" ; more ; str "</ul>" ])
  end) res

end
