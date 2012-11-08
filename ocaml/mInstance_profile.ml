(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Data   = MInstance_data
module Common = MInstance_common 

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "instance-profile" end)

module Design = struct
  module Database = MyDB
  let name = "profile"
end

let only_tag tag = 
  "tag:" ^ Util.fold_all tag
  
let split_name name = 
  List.map Util.fold_all 
    (BatString.nsplit name " ")

module Info = struct
  module T = struct
    module RSS = IPolling.RSS 
    type json t = {
      name     : string ;
      key      : string ;
      address  : string option ;
      contact  : string option ;
      site     : string option ;
      desc     : MRich.OrText.t option ;
      twitter  : string option ;
      facebook : string option ;
      phone    : string option ;
      tags     : string list ;
     ?pic      : IFile.t option ;
     ?search   : bool = false ;
     ?owners   : IUser.t list = [] ;
     ?unbound  : bool = false ;
     ?pub_rss  : (! string, RSS.t ) Ohm.ListAssoc.t = [] ;
     ?white    : IWhite.t option ;
     ?vtag "v" : string list = [] ;
    }

    let json_of_t t = 
      let vtag = 
	BatList.sort_unique compare (
	  List.map Util.fold_all t.tags
	  @ List.map only_tag t.tags 
	  @ split_name t.name
	)
      in
      json_of_t { t with vtag }
	
  end
  include T

  include Fmt.Extend(T)
end

type t = <
  id       : IInstance.t ;
  name     : string ;
  key      : IWhite.key ;
  address  : string option ;
  contact  : string option ;
  site     : string option ;
  desc     : MRich.OrText.t option ;
  twitter  : string option ;
  facebook : string option ;
  phone    : string option ;
  tags     : string list ;
  pic      : [`GetPic] IFile.id option ;
  search   : bool ;
  unbound  : IUser.t list option ;
  pub_rss  : ( string * IPolling.RSS.t ) list
> ;;

let extract iid i = Info.(object
  method id       = IInstance.decay iid
  method key      = i.key, i.white
  method name     = i.name
  method address  = i.address
  method contact  = i.contact
  method site     = i.site
  method desc     = i.desc
  method twitter  = i.twitter
  method facebook = i.facebook
  method phone    = i.phone
  method tags     = i.tags
  method pic      = BatOption.map IFile.Assert.get_pic i.pic (* Can view instance *)
  method search   = i.search 
  method unbound  = if i.unbound then Some i.owners else None
  method pub_rss  = i.pub_rss
end)

module Tbl = CouchDB.Table(MyDB)(IInstance)(Info)

let refresh_all = Async.Convenience.foreach O.async "refresh-instance-profiles"
  IInstance.fmt (Tbl.all_ids ~count:10) 
  (fun iid -> 
    let! profile = ohm_req_or (return ()) $ Tbl.get iid in
    let  search  = Info.(profile.search && not (profile.unbound && profile.owners = [])) in
    let  profile = Info.({ profile with search ; pub_rss = if search then profile.pub_rss else [] }) in
    Tbl.set iid profile)
    
(* Uncomment the line below if the vtag generation function changes *)
(* let () = O.put (refresh_all ()) *)

let empty_info = Info.({
  name  = "" ;
  key   = "" ;
  white = None ;
  address  = None ;
  contact  = None ;
  site     = None ;
  desc     = None ;
  twitter  = None ;
  facebook = None ;
  phone    = None ;
  pic      = None ;
  tags     = [] ;
  search   = false ;
  unbound  = true ;
  owners   = [] ;
  pub_rss  = [] ;
  vtag     = [] 
})

let empty iid = extract iid empty_info
  
let get iid = 
  let iid = IInstance.decay iid in   
  Tbl.using iid (extract iid)
    
let update iid getinfo =
  let update info = getinfo (BatOption.default empty_info info) in
  Tbl.replace (IInstance.decay iid) update

(* Tag stats =============================================================================================== *)

module TagStatsView = CouchDB.ReduceView(struct
  module Key    = Fmt.Make(struct type json t = (IWhite.t option * string) end)
  module Value  = Fmt.Int
  module Design = Design
  let name = "stats_by_tag"
  let map  = "if (doc.search) 
                for (var i = 0; i < doc.tags.length; ++i) {
                   emit([null,doc.tags[i]],1);
                   if (doc.white) emit([doc.white,doc.tags[i]],1);
                }"
  let reduce = "return sum(values)"
  let group  = true
  let level  = None
end)

(* Caching... *)
let tag_stats_cache_ttl = 3600.
let tag_stats_cache = ref None

let tag_stats_get () = 

  let! list = ohm $ TagStatsView.reduce_query () in
  let  list = List.filter (fun (_,count) -> count > 0) list in

  let  map  = List.fold_left (fun map ((owid,tag),count) -> 
    let list = try BatPMap.find owid map with Not_found -> [] in
    BatPMap.add owid ((tag,count) :: list) map
  ) BatPMap.empty list in 

  let  map  = BatPMap.map (List.sort (fun a b -> compare (snd b) (snd a))) map in

  return map

let tag_stats owid = 
  let! time = ohmctx (#time) in
  let cached = match !tag_stats_cache with 
    | Some (map,t) when t +. tag_stats_cache_ttl > time -> Some map
    | _ -> None
  in
  let! map = ohm begin
    match cached with 
      | Some map -> return map
      | None     -> let! map = ohm $ tag_stats_get () in
		    let () = tag_stats_cache := Some (map, time) in
		    return map
  end in
  return (try BatPMap.find owid map with Not_found -> [])

(* Search instances ======================================================================================== *)

module SearchView = CouchDB.DocView(struct
  module Key    = Fmt.Make(struct type json t = (IWhite.t option * string) end)
  module Value  = Fmt.Unit
  module Doc    = Info
  module Design = Design
  let name = "search"
  let map  = "if (doc.search) {
                emit([null,'']);               
                if (doc.white) emit([doc.white,'']);
                for (var i = 0; i < doc.v.length; ++i) 
                  if (doc.v[i]) {
                    emit([null,doc.v[i]]);
                    if (doc.white) emit([doc.white,doc.v[i]]);
                  }
              }"
end)

type search = [`WORD of string | `TAG of string] 

let vtag_of_search = function
  | `WORD w -> Util.fold_all w
  | `TAG  t -> "tag:" ^ Util.fold_all t

let contains_vtags expected = 
  let expected = BatList.sort_unique compare expected in 
  fun vtags ->
    let rec aux = function 
      |       [], _ -> true
      |        _, [] -> false       
      | h1 :: t1, h2 :: t2 when h1 = h2 -> aux (t1,t2)
      | h1 :: t1, h2 :: t2 when h1 < h2 -> false
      |       l1,  _ :: t2 -> aux (l1,t2) 
    in
    aux (expected, vtags)

let search ?start ~count owid search = 

  let startid = BatOption.map IInstance.to_id start in
  let limit   = count + 1 in

  let startkey, endkey, filter = 
    match List.map vtag_of_search search with 
      | [] -> "", "", (fun _ -> true)
      | [x] -> x, x, (fun _ -> true)
      | h :: t -> h, h, contains_vtags t
  in 

  let startkey = owid, startkey and endkey = owid, endkey in

  let! list = ohm $ SearchView.doc_query 
    ~startkey ~endkey ?startid ~limit ~descending:true ()
  in
  
  let list, next = OhmPaging.slice ~count list in 
  
  return begin 
    List.map (fun i -> extract (IInstance.of_id i#id) i#doc) 
      (List.filter (fun i -> filter (i#doc).Info.vtag) list),
    BatOption.map (#id |- IInstance.of_id) next
  end

(* Find the instance bound to an RSS feed ================================================================== *)

module ByRSSView = CouchDB.MapView(struct
  module Key    = IPolling.RSS
  module Value  = Fmt.Unit
  module Design = Design
  let name = "by-rss"
  let map  = "for (var i in doc.pub_rss) emit(doc.pub_rss[i])"
end)

let by_rss rss_id = 
  let! list = ohm $ ByRSSView.by_key rss_id in
  return $ List.map (#id |- IInstance.of_id) list

(* Backdoor manipulation =================================================================================== *)

module Backdoor = struct

  let update iid ~name ~key ~pic ~phone ~desc ~site ~address 
      ~contact ~facebook ~twitter ~tags ~visible ~rss ~owners =     

    let tags = BatList.sort_unique compare (List.map Util.fold_all tags) in

    let rss = BatList.filter_map (fun url -> 
      let url = BatString.strip url in 
      if url = "" then None else
	let _, url = BatString.replace url "https://" "http://" in
	if BatString.starts_with url "http://" then Some url else
	  Some ("http://" ^ url)
    ) rss in

    let rss = BatList.sort_unique compare rss in

    let! pub_rss = ohm $ Run.list_map (fun url -> 
      let! id = ohm $ MPolling.RSS.poll url in return (url, id) 
    ) rss in

    let getinfo obj = Info.({ obj with 
      name ;
      key = fst key ;
      pic ; 
      phone ; 
      desc ; 
      site ; 
      address ; 
      contact ; 
      facebook ; 
      twitter ; 
      tags ; 
      search = visible ;
      pub_rss ; 
      white = snd key ;
      owners ;
    }) in
    
    update iid getinfo

  module CountView = CouchDB.ReduceView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Int
    module Reduced = Fmt.Int
    module Design = Design
    let name   = "backdoor-count"
    let map    = "emit(null,1);"
    let reduce = "return sum(values);"
    let group  = true
    let level  = None
  end)

  let count () = 
    CountView.reduce_query () |> Run.map begin function
      | ( _, v ) :: _ -> v 
      | _ -> 0
    end

  module ByKeyView = CouchDB.MapView(struct
    module Key = Fmt.Make(struct type json t = (string * IWhite.t option) end)
    module Value = Fmt.Unit
    module Design = Design
    let name = "backdoor-by-key"
    let map  = "emit([doc.key,doc.white])"
  end)

  let by_key key = 
    ByKeyView.by_key key |> Run.map begin function 
      | item :: _ -> Some (IInstance.of_id (item # id))
      | [] -> None
    end
    
end
