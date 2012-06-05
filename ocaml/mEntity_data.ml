(* © 2012 MRunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module Data = struct
  module T = struct
    type json t = {
      name   : TextOrAdlib.t option ;
      data   : (!string, Json.t) ListAssoc.t 
    }
  end
  include T
  include Fmt.Extend(T)
end

module EntityDataConfig = struct

  let name = "entity-data"
  module Id = IEntity
  module DataDB = CouchDB.Convenience.Config(struct let db = O.db "entity-data" end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "entity-data-v" end)
  module Data = Data  

  type ctx = O.ctx
  let couchDB ctx = (ctx :> CouchDB.ctx) 

  module Diff = Fmt.Make(struct
    type json t = 
      [ `Set    of (!string, Json.t) ListAssoc.t 
      |	`Fields of Json.t
      | `Info   of Json.t 
      | `Name   of TextOrAdlib.t option
      ]
  end)

  module VersionData = MUpdateInfo

  module ReflectedData = Fmt.Unit

  let merge from into = 
    List.fold_left (fun into (key,value) -> ListAssoc.set key value into) into from

  let apply = function
    | `Set    data  -> return (fun id time t -> return { t with Data.data = merge data t.Data.data })
    | `Fields diffs -> return (fun id time t -> return t)
    | `Info   diffs -> return (fun id time t -> return t)
    | `Name   name  -> return (fun id time t -> return { t with Data.name = name })

  let reflect id data = return ()

end

module Store = OhmCouchVersioned.Make(EntityDataConfig)

let create ~id ~who ?name ?data () = 

  let diffs = match data with None -> [] | Some data -> [`Set data] in
  let diffs = match name with None -> diffs | Some name -> (`Name name) :: diffs in

  Store.create ~id:(IEntity.decay id)
    ~init:{ Data.data = [] ; Data.name = None }
    ~diffs:(diffs)
    ~info:(MUpdateInfo.info ~who)
    ()

  |> Run.map ignore
  
let update ~id ~who ?name ~data () = 
  
  let! obj = ohm_req_or (return ()) $ Store.get (IEntity.decay id) in
  let current = Store.current obj in

  let name =
    (* Only update name if it changed *)
    match name with None -> None | Some name ->
      if name = current.Data.name then None else Some name
  in

  let data = 
    (* Only keep data CHANGES *)    
    List.filter (fun (k,v) -> v <> (try List.assoc k current.Data.data with Not_found -> Json.Null)) data
  in

  let diffs = match data with [] -> [] | data -> [`Set data] in    
  let diffs = match name with None -> diffs | Some name -> (`Name name) :: diffs in

  if diffs = [] then return () else

    Store.update ~id:(IEntity.decay id) ~diffs ~info:(MUpdateInfo.info ~who) ()
    |> Run.map ignore

type 'a t = Data.t 

let get id = Store.get (IEntity.decay id) |> Run.map (BatOption.map Store.current)

let description tmpl t = 
  match PreConfig_Template.Meaning.description tmpl with 
    | None -> None
    | Some field -> 
      try let value = List.assoc field t.Data.data in
	  Some (Json.to_string value)
      with _ -> None

let data   t = t.Data.data
let name   t = t.Data.name

module Signals = struct

  let update_call, update = Sig.make (Run.list_iter identity)
    
  let _ = 
    Sig.listen Store.Signals.update
      (fun t -> update_call (IEntity.Assert.bot (Store.id t)))

end
