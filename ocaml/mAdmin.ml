(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module MAdmin = Fmt.Make(struct
  type json t = < users : Id.t list > ;;
end)

module MyTable = CouchDB.Table(O.ConfigDB)(Id)(MAdmin)

let _admin : MAdmin.t = 
  let id = Id.of_string "admin" in
  let get = MyTable.get id |> Run.map begin function
    | None -> 
      log "Admin : could not load admin configuration object" ;
      (object method users = [] end)
    | Some obj -> 
      log "Admin : configuration loaded" ;
      obj
  end in
  get |> Run.eval (new CouchDB.init_ctx)
      
let user_is_admin uid = 
  let id = ICurrentUser.to_id uid in
  if List.mem id (_admin # users) then Some (ICurrentUser.Assert.is_admin uid) else None

let user_may_be_admin uid = 
  let id = IUser.to_id (IUser.decay uid) in 
  List.mem id (_admin # users) 

let map f = 
  List.map (fun id -> f (ICurrentUser.Assert.is_admin (ICurrentUser.of_id id))) (_admin # users) 

let list () = List.map IUser.of_id _admin # users 
