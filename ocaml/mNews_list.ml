(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MNews_common

(* Retrieving news data from the database *)

let max_depth = 5 (* Never do more than this number of requests *)
let fetch_size = 30 (* how many items to fetch in a single call *)

let memoized_access ctx = 

  let access = MAccess.test ctx in
  let try_access miniAccess = let! a = ohm $ access_of_miniAccess miniAccess in access a in 

  let access_memo = Hashtbl.create 10 in
  let access miniAccess = 
    try return (Hashtbl.find access_memo miniAccess) with Not_found ->
      try_access miniAccess |> Run.map (fun x -> Hashtbl.add access_memo miniAccess x ; x) 
  in

  access

module ByInstanceView = CouchDB.DocView(struct

  module Key = Fmt.Make(struct
    module Float = Fmt.Float
    type json t = IInstance.t * Float.t
  end)

  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design

  let name = "by_instance"
  let map  = "if (doc.t == 'news' && doc.i && !doc.b) emit([doc.i,doc.time],null)"

end)

let by_instance ~instance ~ctx ~not_avatar start = 

  let count   = fetch_size in
  let access  = memoized_access ctx in 

  let rec fetch depth start = 
    if depth >= max_depth then return ([],start) else begin    

      let! now = ohmctx (#time) in
      let startkey = instance, BatOption.default now start in
      let endkey   = instance, 0.0 in

      let! list = ohm $
	ByInstanceView.doc_query 
	~descending:true
	~limit:(count+1) 
	~startkey
	~endkey ()
      in
      
      let list, next = OhmPaging.slice ~count list in 
      let list = List.map (#doc) list in
      let next = BatOption.map (#key |- snd) next in  

      let! accessible = ohm $
	Run.list_filter begin fun doc -> 
	  Run.list_exists access (doc # restrict)
  	  |> Run.map (fun ok -> if ok then Some doc else None)
	end list
      in
								   
      let accessible = match not_avatar with None -> accessible | Some avatar ->
	BatList.filter_map begin fun doc ->
	  if doc # avatar = Some avatar then None else Some doc	  
	end accessible
      in
      
      match accessible, next with 
	| [], None -> return ([], None)
	| [], next -> fetch (depth + 1) next
	| _ -> let list = BatList.filter_map (#payload |- t_of_payload) accessible in
	       return (list, next)      
    end
  in
  
  fetch 0 start 

module ByAvatarView = CouchDB.DocView(struct

  module Key = Fmt.Make(struct
    module Float = Fmt.Float
    type json t = IAvatar.t * Float.t
  end)

  module Value = Fmt.Unit
  module Doc = Data
  module Design = Design

  let name = "by_avatar"
  let map  = "if (doc.t == 'news' && doc.a && !doc.b) emit([doc.a,doc.time],null)"

end)

let by_avatar  ~avatar ~ctx start = 

  let count   = fetch_size in 
  let access  = memoized_access ctx in 

  let rec fetch depth start = 
    if depth >= max_depth then return ([],start) else begin

      let! now = ohmctx (#time) in
      let startkey = avatar, BatOption.default now start in
      let endkey   = avatar, 0.0 in

      let! list = ohm $	ByAvatarView.doc_query
	~descending:true 
	~limit:(count+1)
	~startkey
	~endkey ()
      in

      let list, next = OhmPaging.slice ~count list in 
      let list = List.map (#doc) list in
      let next = BatOption.map (#key |- snd) next in  

      let! accessible = ohm $
	Run.list_filter begin fun doc -> 
	  Run.list_exists access (doc # restrict)
  	  |> Run.map (fun ok -> if ok then Some doc else None)
	end list
      in

      match accessible, next with 
	| [], None -> return ([], None)
	| [], next -> fetch (depth + 1) next
	| _ -> let list = BatList.filter_map (#payload |- t_of_payload) accessible in
	       return (list, next)      
      
    end
  in

  fetch 0 start
