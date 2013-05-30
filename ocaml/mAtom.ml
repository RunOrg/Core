(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let max_label_size = 100

type t = <
  id      : IAtom.t ; 
  nature  : IAtom.Nature.t ;
  label   : string ;
  hide    : bool ; 
  limited : bool ;
> ;;

module Data = struct
  module T = struct
    type json t = {
      nature : IAtom.Nature.t ;
      more   : IAtom.Nature.t list ;
      label  : string ; 
      iid    : IInstance.t ;
     ?hide   : bool = false ; 
     ?lim    : bool = false ; 
      sort   : string list 
    }
  end
  include T
  include Fmt.Extend(T)
end

include CouchDB.Convenience.Table(struct let db = O.db "atom" end)(IAtom)(Data)

let to_sort label = 
  let clean = Util.fold_accents label in
  let clean = 
    List.fold_left (fun clean (reg,rep) ->
      Str.global_replace (Str.regexp reg) rep clean) clean
      [ "[^A-Za-z0-9]"    , " " ;
	" +"              , " " ;
	"^ +"             , ""  ;
	" +$"             , ""  ]
    |> String.lowercase
  in
  BatList.sort_unique compare (BatString.nsplit clean " ") 

(* Limit filtering *)

let filters = Hashtbl.create 10

let access_register nature f = 
  Hashtbl.add filters nature f 

let limitFilter nature actor id = 
  let! actor = req_or (return false) (MActor.member actor) in
  try Hashtbl.find filters nature actor id with Not_found -> return false

(* Querying multiple elements *) 

module All = struct

  module ByNature = CouchDB.DocView(struct
    module Key = Fmt.Make(struct type json t = (IInstance.t * IAtom.Nature.t option * string) end)
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name = "by_nature"
    let map  = "function out(nature) { 
                  for (var i = 0; i < doc.sort.length; ++i)
                    emit([doc.iid, nature, doc.sort[i]]);
                }
                if ('hide' in doc && doc.hide) return;
                out(null);
                out(doc.nature);
                for (var i = 0; i < doc.more.length; ++i) 
                  out(doc.more[i]);"
  end)

  (* Determines whether we have exceeded the current segment. When this filter starts 
     returning false, abort the search : nothing else will be found. *)
  let filter_lvl1 qseg item =
    let _, _, sseg = item # key in
    BatString.starts_with sseg qseg 

  (* Determines whether the current element satisfies all the other query segments. 
     Items may be removed by this filter without preventing MORE items to be found
     subsequently. *)
  let filter_lvl2 query item = 
    let rec is_subset = function 
      | [], _ -> true
      | _, [] -> false
      | x :: xs, y :: ys -> 
	if BatString.starts_with y x then is_subset (xs,y :: ys)
	else if x < y then false
	else is_subset (x :: xs, ys)
    in

    is_subset (query,(item # doc).Data.sort)

  (* Determines whether the current element is either not limited, or satistfies
     the accessibility filter (e.g. a secret group can be seen by this user). *)
 
  let filter_lvl3 filter item = 
    let doc = item # doc in 
    if not doc.Data.lim then return (Some item) else 
      let! ok = ohm (filter doc.Data.nature (item # id)) in
      return (if ok then Some item else None)

  let extract item = object
    val id = IAtom.of_id (item # id) 
    method id = id
    val nature = (item # doc).Data.nature
    method nature = nature
    val label = (item # doc).Data.label
    method label = label
    method hide = false
    val limited = (item # doc).Data.lim
    method limited = limited
  end
     
  let fetch_at_least ~filter ~count iid nature query = 

    let qseg, query = match query with [] -> "", [] | x :: xs -> x, xs in
    let lvl1 = filter_lvl1 qseg in
    let lvl2 = filter_lvl2 query in
    let lvl3 = filter_lvl3 filter in 

    let rec fetch_more ~count ?startid prefix = 

      let startkey = iid, nature, prefix in
      let endkey   = iid, nature, "~" in  (* '~' comes after all "sort" -compatible characters *)
      let limit    = count + 1 in

      let! raw = ohm (ByNature.doc_query ~startkey ~endkey ?startid ~limit ()) in 
      
      (* These lines ensure that "next" is None if at least one item was filtered
	 at lvl1, thus preventing recursion. *)
      let  postlvl1 = List.filter lvl1 raw in
      let  postlvl1, next = OhmPaging.slice ~count postlvl1 in
      
      (* Eliminate all partial matches *)
      let  postlvl2 = List.filter lvl2 postlvl1 in
      
      (* Eliminate duplicate atoms (by IAtom) *)
      let  unique   = BatList.sort_unique (fun a b -> compare (a # id) (b # id)) postlvl2 in

      (* Eliminate inaccessible atoms. *)
      let! postlvl3 = ohm (Run.list_filter lvl3 unique) in

      let  result   = List.map extract postlvl3 in

      (* If not up to count yet, keep searching. *)
      let found = List.length result in 
      if found >= count then return [result] else 
	let! next = req_or (return [result]) next in 
	let  startid = next # id in
	let  _,_,prefix = next # key in
	let! recurse = ohm $ fetch_more ~count:(count - found) ~startid prefix in 
	return (result :: recurse)

    in

    let! lists = ohm (fetch_more ~count qseg) in 
    let  list  = List.concat lists in
    return (List.sort (fun a b -> compare (a # label) (b # label)) list) 

  let suggest_public iid ?nature ~count query = 
    let  query  = to_sort query in 
    let  filter _ _ = return false in 
    fetch_at_least ~filter ~count iid nature query

  let suggest actor ?nature ~count query = 
    let query = to_sort query in
    let filter nid id = O.decay (limitFilter nid actor id) in
    let iid = IInstance.decay (MActor.instance actor) in 
    fetch_at_least ~filter ~count iid  nature query 
      
end

let get ~actor atid = 
  let! atom = ohm_req_or (return `Missing) (Tbl.get atid) in
  let  iid  = IInstance.decay (MActor.instance actor) in
  if iid <> atom.Data.iid then return `Missing else 
    let obj = `Some (object
      method id      = atid 
      method nature  = atom.Data.nature
      method label   = atom.Data.label 
      method hide    = atom.Data.hide
      method limited = atom.Data.lim
    end) in
    if not atom.Data.lim then return obj else 
      let! visible = ohm (O.decay (limitFilter atom.Data.nature actor (IAtom.to_id atid))) in
      if visible then return obj else return (`Limited atom.Data.nature)

let create actor nature label = 
  if not (IAtom.Nature.can_create nature) then return None else
    let label = BatString.head (BatString.strip label) max_label_size in
    if label = "" then return None else 
      let sort = to_sort label in
      if sort = [] then return None else
	let iid  = IInstance.decay (MActor.instance actor) in 
	let more = IAtom.Nature.parents nature in 
	let data = Data.({ 
	  nature ;
	  more ;
	  label ;
	  sort ;
	  hide = false ; 
	  lim = false ;
	  iid
	}) in
	let! atid = ohm (Tbl.create data) in
	return (Some atid) 
	
let reflect iid nature id ?(lim=false) ?(hide=false) label = 
  let atid = IAtom.of_id id in 
  let label = BatString.head (BatString.strip label) max_label_size in 
  if label = "" then return () else
    let sort = to_sort label in 
    if sort = [] then return () else
      let more = IAtom.Nature.parents nature in 
      let data = Data.({
	nature ;
	more ;
	sort ;
	label ;
	hide ; 
	lim ; 
	iid
      }) in
      Tbl.set atid data

let of_json ~actor json = 
  let! atid = req_or (return None) (IAtom.of_json_safe json) in
  let! atom = ohm (get ~actor atid) in
  match atom with 
    | `Some atom -> return (Some (atom # label))
    | `Missing
    | `Limited _ -> return None

module PublicFormat = Fmt.Make(struct
  type json t = 
    [ `Saved   "s" of IAtom.t 
    | `Unsaved "u" of IAtom.Nature.t * string
    ]
end)

