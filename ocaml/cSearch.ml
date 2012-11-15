(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

let () = UrlClient.Search.def_avatars $ CClient.action begin fun access req res ->

  let  iid   = IInstance.Deduce.token_see_contacts (access # iid) in

  let! list  = ohm $ MAvatar.search iid "" 12 in

  let! htmls = ohm $ Run.list_filter begin fun (aid,prefix,details) ->
    let! name = req_or (return None) (details # name) in
    let! status = req_or (return None) (details # status) in
    let! pic  = ohm $ CPicture.small_opt (details # picture) in
    let  data = object
      method id = aid 
      method name = name
      method pic  = pic
      method status = status
    end in 
    let! html = ohm $ Asset_Search_Avatar.render data in
    return (Some (Html.to_json html))
  end list in

  return (Action.json [ "list", Json.Array htmls ] res)

end
