(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

(* Database definition --------------------------------------------------------------------- *)

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "avatar-pending" end)

module Design = struct
  module Database = MyDB
  let name = "avatar"
end

module Data = struct
  module Float = Fmt.Float
  module IInstance = IInstance
  module IUser = IUser
  module T = struct
    type json t = {
      user     : IUser.t ;
      instance : IInstance.t ;
      invited  : Float.t option ;  
      joined   : Float.t option  
    }
  end
  include T
  include Fmt.Extend(T)
end

module MyTable = CouchDB.Table(MyDB)(IAvatar)(Data) 

(* Unitary creation procedures ------------------------------------------------------------- *)

let invite ?time ?uid ?iid id = 
  
  let time = BatOption.default (Unix.gettimeofday ()) time in
  
  let update id = 

    let return x = return ( (), x ) in
    let nothing = return `keep  in

    let! t_opt = ohm $ MyTable.get id in
    match t_opt with 
      | None   -> begin
	match uid, iid with 
	  | Some uid, Some iid ->
	    let! confirmed = ohm $ MUser.confirmed uid in 
	    return (`put Data.({
	      invited = Some time ;
	      user = uid ;
	      instance = iid ;
	      joined = if confirmed then Some (time -. 1.) else None
	    }))
	  | _, _ -> nothing
      end
      | Some t -> nothing
  in

  MyTable.transaction id update

let join ?time ?uid ?iid id = 
  
  let time = BatOption.default (Unix.gettimeofday ()) time in
  
  let update id = 

    let return x = return ( (), x ) in
    let nothing = return `keep  in

    let! t_opt = ohm $ MyTable.get id in
    match t_opt with 
      | None   -> begin
	match uid, iid with 
	  | Some uid, Some iid -> 
	    return (`put Data.({
	      invited = None ;
	      user = uid ;
	      instance = iid ;
	      joined = Some time
	    }))
	  | _, _ -> nothing 
      end
      | Some t -> 
	if t.Data.joined = None
	then return (`put Data.({t with joined = Some time }))
	else nothing
  in

  MyTable.transaction id update

(* MUser confirmation process --------------------------------------------------------------- *)

module UnconfirmedByUserView = CouchDB.DocView(struct
  module Design = Design
  module Key = IUser
  module Value = Fmt.Unit
  module Doc = Data
  let name = "unconfirmed_by_user"
  let map  = "if (!doc.joined) emit(doc.user,null)"
end)

let all_unconfirmed_by_user uid = 
  let! list = ohm $ UnconfirmedByUserView.doc uid in
  return $ List.map (#id |- IAvatar.of_id) list

let confirm_user =
  let task = Task.register "avatar-confirm-user" IUser.fmt begin fun uid self ->
    let! list = ohm $ all_unconfirmed_by_user uid in
    let! _    = ohm $ Run.list_iter join list in
    return $ Task.Finished uid 
  end in
  fun uid -> 
    let! _ = ohm $ MModel.Task.call task uid in
    return ()

let _ = 
  Sig.listen MUser.Signals.on_confirm
    (fun (uid,_) -> confirm_user (IUser.decay uid))

(* Confirmed users history --------------------------------------------------------------- *)

module ConfirmedHistoryView = CouchDB.MapView(struct

  module Design = Design
  module Key    = Fmt.Make(struct
    module IInstance = IInstance
    module Float = Fmt.Float
    type json t = IInstance.t * Float.t
  end)
  module Value  = Fmt.Unit

  let name = "confirmed_by_instance"
  let map  = "if (doc.joined) emit([doc.instance,doc.joined],null)" 

end)

let get_latest_confirmed ~count ?start iid = 

  let! now = ohm (Run.context |> Run.map (#time)) in
  
  let! list = ohm $ ConfirmedHistoryView.query
    ~descending:true
    ~limit:(count+1)
    ~startkey:(IInstance.decay iid,BatOption.default now (BatOption.map fst start))
    ?startid:(BatOption.map (snd |- IAvatar.to_id) start)
    ~endkey:(IInstance.decay iid,0.0) 
    ()
  in

  let list, next = OhmPaging.slice ~count list in
  let list = List.map (fun i -> IAvatar.of_id (i#id), snd (i # key)) list in
  let next = BatOption.map (fun i -> snd (i#key), IAvatar.of_id (i#id)) next in
  return (list, next)

let obliterate aid = 
  let! _ = ohm $ MyTable.transaction aid MyTable.remove in
  return () 
  
