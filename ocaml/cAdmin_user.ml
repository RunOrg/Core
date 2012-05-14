(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let csv_head = [
  "Prénom" ;
  "Nom" ;
  "Email" ;
  "Confirmé?" ;
  "Association?" ;
  "Contact" ;
  "Membre" ;
  "Administrateur"
]

let csv_of_user (user,member,contact,token,admin) = [
  BatOption.default "" user # firstname ;
  BatOption.default "" user # lastname ;
  user # email ;
  OhmCsv.datetime user # join ;
  if member then "YES" else "NO" ;
  String.concat ", " contact ;
  String.concat ", " token ;
  String.concat ", " admin ;
]

let to_csv users = 
  OhmCsv.to_csv csv_head (List.map csv_of_user users) 
  
let () = CAdmin_common.register UrlAdmin.Csv.users begin fun i18n user request response ->
  
  let! users     = ohm MUser.Backdoor.all in
  let! avatars   = ohm MAvatar.Backdoor.all in
  let! instances = ohm MInstance.Backdoor.key_by_id in 

  let instance_by_id = Hashtbl.create 1000 in
  let () = List.iter (fun (id,key) -> Hashtbl.add instance_by_id id key) instances in

  let avatars_by_user = Hashtbl.create 5000 in
  let () = List.iter (fun (who,ins,sta) -> 
    try let key = Hashtbl.find instance_by_id ins in
	let current = try Hashtbl.find avatars_by_user who with _ -> [] in
	Hashtbl.remove avatars_by_user who ;
	Hashtbl.add avatars_by_user who ((sta,key) :: current)
    with _ -> ()
  ) avatars in
 
  let data = List.map begin fun (id,user) ->

    try let avatars = Hashtbl.find avatars_by_user id in

	let by_status s = BatList.filter_map
	  (fun (sta,key) -> if sta = s then Some key else None) avatars
	in
	
	let contacts = by_status `Contact in
	let tokens   = by_status `Token in
	let admins   = by_status `Admin in
	(user,true,contacts,tokens,admins)

    with _ -> (user,false,[],[],[])
  end users in

  let data = to_csv data in 

  return (
    Action.file ~file:"users.csv" ~mime:"text/csv" ~data response
  )

end

