(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

let empty ~count ?start access atid = 
  return ([], None)

(* Filter management *)

type query = 
    count:int
 -> ?start:Ohm.Json.t 
 -> [`IsToken] CAccess.t
 -> IAtom.t 
 -> (Ohm.Html.writer list * Ohm.Json.t option) O.run

let filters = ref ([] : (string * (O.i18n * query)) list)

let addFilter ~key ~label ~query = 
  filters := (key, (label, query)) :: !filters

let () = 
  addFilter ~key:"avatars"     ~label:`Atom_Filter_Avatars     ~query:empty ;
  addFilter ~key:"groups"      ~label:`Atom_Filter_Groups      ~query:empty ;
  addFilter ~key:"events"      ~label:`Atom_Filter_Events      ~query:empty ;
  addFilter ~key:"discussions" ~label:`Atom_Filter_Discussions ~query:empty 

let filter_all = "all"

let filterQueryByName = lazy 
  (List.fold_left (fun map (key, (_,query)) -> BatMap.add key query map) BatMap.empty !filters)

let filterLabels = lazy 
  ((filter_all, `Atom_Filter_All) :: List.rev_map (fun (key,(label,_)) -> (key, label)) !filters)
  
let allFilters = lazy 
  (List.rev_map fst !filters) 

let filtersByKey key = 
  if BatMap.mem key (Lazy.force filterQueryByName) then key, [ key ] else filter_all, Lazy.force allFilters 

(* Search management *)

module SearchFmt = Fmt.Make(struct
  type json t = <
    start : string list ;
    next  : (string * Json.t) list
  >
end)

(* View core *)

let () = CClient.define UrlClient.Atom.def_view begin fun access -> 

  let! atid = O.Box.parse IAtom.seg in 
  let! filter = O.Box.parse OhmBox.Seg.string in 

  let  filter, queryFilters = filtersByKey filter in

  let  render_more react search = 
    VMore.div (OhmBox.reaction_endpoint react search, Json.Null)
  in

  let! more = O.Box.react SearchFmt.fmt begin fun search _ self res ->
    let count = 8 in
    let query key = try BatMap.find key (Lazy.force filterQueryByName) with Not_found -> empty in
    let result htmls search = 
      let! more = ohm (render_more self search) in
      let  html = Html.concat (htmls @ [more]) in
      return (Action.json ["more", Html.to_json html] res) 
    in
    match search # start with 
      | key :: xs -> let! htmls, next = ohm (O.decay (query key ~count access atid)) in
		     result htmls (object
		       method start = xs
		       method next = match next with 
			 | None -> search # next
			 | Some json -> search # next @ [key, json] 
		     end) 
      | [] -> match search # next with 
	  | (key, start) :: xs -> let! htmls, next = ohm (O.decay (query key ~count ~start access atid)) in
				  result htmls (object
				    method start = []
				    method next = match next with 
				      | None -> xs
				      | Some json -> xs @ [key, json]
				  end) 
	  | [] -> let! html = ohm (Asset_Atom_SearchEmpty.render ()) in
		  return (Action.json ["more", Html.to_json html] res)
  end in

  O.Box.fill begin 

    let missing = Asset_Client_PageNotFound.render () in

    let! atom = ohm_req_or missing begin 
      let! result = ohm (MAtom.get ~actor:(access # actor) atid) in
      match result with
        | `Some atom -> return (Some atom) 
	| `Missing
	| `Limited _ -> return None
    end in 
    
    let! filters = ohm $ Run.list_map begin fun (filter',label) -> 
      let! url = ohm (O.Box.url [ IAtom.to_string atid ; filter' ]) in
      let! label = ohm (AdLib.get label) in
      return (object
	method sel = filter = filter'
	method name = label
	method url = url 
      end)
    end (Lazy.force filterLabels) in 

    let more = render_more more (object
      method next  = []
      method start = queryFilters 
    end) in 

    Asset_Atom_Wrap.render (object
      method title = atom # label 
      method filters = filters
      method body = more 
    end)
    
  end 

end 
