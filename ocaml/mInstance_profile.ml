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
  
module Info = struct
  module T = struct
    module RSS = IPolling.RSS 
    type json t = {
      name     : string ;
      key      : string ;
      address  : string option ;
      contact  : string option ;
      site     : string option ;
      desc     : string option ;
      twitter  : string option ;
      facebook : string option ;
      phone    : string option ;
      tags     : string list ;
      pic      : IFile.t option = None ;
      search   : bool = false ;
     ?unbound  : bool = false ;
     ?pub_rss  : ( string * RSS.t ) assoc = [] 
    }
  end
  include T
  include Fmt.Extend(T)
end

type t = <
  id       : IInstance.t ;
  name     : string ;
  key      : string ;
  address  : string option ;
  contact  : string option ;
  site     : string option ;
  desc     : string option ;
  twitter  : string option ;
  facebook : string option ;
  phone    : string option ;
  tags     : string list ;
  pic      : [`GetPic] IFile.id option ;
  search   : bool ;
  unbound  : bool ;
  pub_rss  : ( string * IPolling.RSS.t ) list
> ;;

let extract iid i = Info.(object
  method id       = IInstance.decay iid
  method key      = i.key
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
  method unbound  = i.unbound
  method pub_rss  = i.pub_rss
end)

module MyTable = CouchDB.Table(MyDB)(IInstance)(Info)

let empty_info = Info.({
  name = "" ;
  key  = "" ;
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
  pub_rss  = [] ;
})

let empty iid = extract iid empty_info
  
let get iid = 
  let iid = IInstance.decay iid in   
  let! data = ohm_req_or (return None) $ MyTable.get iid in
  return (Some (extract iid data))
    
let update iid getinfo =

  let update iid = 
    let! info_opt = ohm $ MyTable.get iid in 
    let  info     = BatOption.default empty_info info_opt in
    let  newinfo  = getinfo info in
    return ((), `put newinfo)
  in

  let! _ = ohm $ MyTable.transaction (IInstance.decay iid) update in
  return ()     

module TagView = CouchDB.DocView(struct
  module Key    = Fmt.String
  module Value  = Fmt.Unit
  module Doc    = Info
  module Design = Design
  let name = "by_tag"
  let map  = "if (doc.search) for (var i = 0; i < doc.tags.length; ++i) emit(doc.tags[i],1)"
end)

let by_tag ?start ~count tag = 

  let tag = Util.fold_all tag in
  let startkey = tag and endkey = tag and limit = count + 1 
  and startid = BatOption.map IInstance.to_id start in

  let! list = ohm $ TagView.doc_query 
    ~startkey ~endkey ?startid ~limit ~descending:true ()
  in
  
  let list, next = OhmPaging.slice ~count list in 
  
  return begin 
    List.map (fun i -> extract (IInstance.of_id i#id) i#doc) list,
    BatOption.map (#id |- IInstance.of_id) next
  end

module TagStatsView = CouchDB.ReduceView(struct
  module Key    = Fmt.String
  module Value  = Fmt.Int
  module Design = Design
  let name = "stats_by_tag"
  let map  = "if (doc.search) for (var i = 0; i < doc.tags.length; ++i) emit(doc.tags[i],1)"
  let reduce = "return sum(values)"
  let group  = true
  let level  = None
end)

let tag_stats () = 
  let! list = ohm $ TagStatsView.reduce_query () in
  let  list = List.filter (fun (tag,count) -> count > 0) list in
  let  list = List.sort (fun a b -> compare (snd b) (snd a)) list in
  return list

module AllView = CouchDB.DocView(struct
  module Key    = Fmt.Unit
  module Value  = Fmt.Unit
  module Doc    = Info
  module Design = Design
  let name = "searchable"
  let map  = "if (doc.search) emit(null)"
end)

let all ?start ~count () = 

  let startkey = () and endkey = () and limit = count + 1 
  and startid = BatOption.map IInstance.to_id start in

  let! list = ohm $ AllView.doc_query 
    ~startkey ~endkey ?startid ~limit ~descending:true () 
  in
  
  let list, next = OhmPaging.slice ~count list in 
  
  return begin 
    List.map (fun i -> extract (IInstance.of_id i#id) i#doc) list,
    BatOption.map (#id |- IInstance.of_id) next
  end

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

module Backdoor = struct

  let update iid ~name ~key ~pic ~phone ~desc ~site ~address 
      ~contact ~facebook ~twitter ~tags ~visible ~rss =     

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
      key ;
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

    
end
