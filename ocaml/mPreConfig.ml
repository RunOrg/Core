(* © 2012 MRunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module MyDB = MModel.TemplateDB
module Design = struct
  module Database = MyDB
  let name = "preconfig"
end

(* MType definitions ------------------------------------------------------------------------ *)

module AccessConfig = Fmt.Make(struct
  module AccessAction = MAccess.Action
  module AccessState  = MAccess.State
  type json t = [ `Nobody 
		| `Admin
		| `Token
		| `Contact
		| `Entity of string * AccessAction.t
		| `Group  of string * AccessState.t
		]      
end)

(* A functor for representing saved versions in the database. ------------------------------ *)

module type VERSION_DEF = sig
  module Id : Fmt.FMT
  module Payload : Fmt.FMT
  val name : string 
  val t : MType.t
  val names : Payload.t -> (string * string) list
end

module Saved = functor (Version:VERSION_DEF) -> struct

  module VId = Version.Id
  module VPayload = Version.Payload

  let typekey = 
    Json.to_string (MType.to_json Version.t)

  module Data = Fmt.Make(struct
    type json t = <
      t : MType.t ;
      ok : bool ;
      version : string ;
      applies : VId.t list ;
      payload : VPayload.t list ;
     ?names : (!string, (string list)) ListAssoc.t = []
    >
  end)

  let print e = 
    Printf.sprintf "==== %s (for %s) ====\n  %s"
      (e # version)
      (String.concat ", " (List.map VId.to_json_string (e # applies)))
      (String.concat "\n  " (List.map VPayload.to_json_string (e # payload)))
 
  module MyTable = CouchDB.Table(MyDB)(Id)(Data)

  module AllView = CouchDB.DocView(struct
    module Key = Fmt.Unit
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name = "all_"^Version.name
    let map = "if (doc.t == "^typekey^" && doc.ok) emit(null,null);"
  end)

  let get_all = 
    let! all = ohm $ AllView.doc_query () in
    return $ List.map (#doc) all

  module ForView = CouchDB.DocView(struct
    module Key = Version.Id
    module Value = Fmt.Unit
    module Doc = Data
    module Design = Design
    let name = "for_"^Version.name
    let map = "if (doc.t == "^typekey^" && doc.ok) 
                 for (var i in doc.applies) 
                   emit(doc.applies[i],null);"
  end)

  let get_for id = 
    let! list = ohm $ ForView.doc_query ~startkey:id ~endkey:id ~endinclusive:true () in
    let sorted = 
      List.sort (fun a b -> compare a#version b#version) $ List.map (#doc) list
    in
    return sorted

  let extract_names payload = 
    ListAssoc.group (List.concat (List.map Version.names payload))

  let save_with_id id applies payload =

    let obj = object
      method t       = Version.t
      method ok      = true
      method version = Id.str id
      method applies = applies
      method payload = payload
      method names   = extract_names payload
    end in 

    let! _ = ohm $ MyTable.transaction id (MyTable.insert obj) in

    return ()

  let save applies payload = 
    let id = Id.gen () in
    save_with_id id applies payload
    
  let overwrite list last =

    (* Remove existing versions *)
    let! all = ohm $ AllView.doc_query () in
    let! ()  = ohm $ Run.list_iter (fun item -> 
      MyTable.transaction (item # id) MyTable.remove |> Run.map ignore
    ) all in

    (* Insert new versions *)
    let! () = ohm $ Run.list_iter (fun v -> 
      save_with_id 
	(Id.of_string (v # version))
	(v # applies)
	(v # payload)
    ) list in

    let! _ = ohm $ save_with_id (Id.of_string last) [] [] in

    return ()

end

(* Name extraction ------------------------------------------------------------------------ *)

module NameView = CouchDB.ReduceView(struct
  module Key = Fmt.Make(struct
    type json t = string * string
  end)
  module Value = Fmt.Unit
  module Reduced = Fmt.Unit
  module Design = Design
  let name = "names"
  let map = "if ('names' in doc) 
               for (var k in doc.names) 
                 for (var j in doc.names[k])
                   emit([k,doc.names[k][j]],null);"
  let reduce = "return null;"
  let group  = true
  let level  = None
end)
  
let name_suggestions = 
  let! all = ohm $ NameView.reduce_query () in
  return (List.map fst all |> ListAssoc.group)     

(* Template versions ----------------------------------------------------------------------- *)

module TemplateDiff = Fmt.Make(struct

  module EntityConfigDiff = MEntityConfig.Diff
  module EntityInfoDiff   = MEntityInfo.Diff
  module EntityFieldsDiff = MEntityFields.Diff
  module GroupColumnDiff  = MGroupColumn.Diff
  module JoinFieldsDiff   = MJoinFields.Diff
  module GroupPropagateDiff = MGroupPropagate.Entity.Diff
    
  type json t = [ `Config of EntityConfigDiff.t 
		| `Info   of EntityInfoDiff.t 
		| `Field  of EntityFieldsDiff.t 
		| `Column of GroupColumnDiff.t
		| `Join   of JoinFieldsDiff.t 
		| `Propagate of GroupPropagateDiff.t ]
      
(*
  let edit = JoyA.variant [
    "Info"   |> JoyA.alternative ~label:"Affichage"     ~content:MEntityInfo.Diff.edit ;
    "Field"  |> JoyA.alternative ~label:"Champs Entité" ~content:MEntityFields.Diff.edit ;
    "Column" |> JoyA.alternative ~label:"Colonnes"      ~content:MGroupColumn.Diff.edit ;
    "Config" |> JoyA.alternative ~label:"Configuration" ~content:MEntityConfig.Diff.edit ;
    "Join"   |> JoyA.alternative ~label:"Champs Fiches" ~content:MJoinFields.Diff.edit ;
    "Propagate" |> JoyA.alternative ~label:"Inscription automatique"
	~content:MGroupPropagate.Entity.Diff.edit ;
  ]
*)   
end)

module TemplateVersion = struct
  module Id = ITemplate
  module Payload = TemplateDiff
  let name = "template"
  let t = `TemplateVersion

  let names = function 
    | `Config c -> MEntityConfig.names c
    | `Info   i -> MEntityInfo.names i
    | `Field  f -> MEntityFields.names f
    | `Column c -> MGroupColumn.names c
    | `Join   j -> MJoinFields.names j
    | `Propagate p -> MGroupPropagate.Entity.names p
end

module SavedTemplateVersion = Saved(TemplateVersion)

(* Vertical versions ----------------------------------------------------------------------- *)

module VerticalDiff = Fmt.Make(struct

  module InstanceEntityDiff = MInstanceEntity.Diff
  module GroupPropagateDiff = MGroupPropagate.Diff
    
  type json t =
    [ `Entities of InstanceEntityDiff.t
    | `Propagate of GroupPropagateDiff.t ]
(*
  let edit = JoyA.variant [
    "Entities" |> JoyA.alternative ~label:"Entités" ~content:MInstanceEntity.Diff.edit ;
    "Propagate" |> JoyA.alternative ~label:"Inscription Automatique"
	~content:MGroupPropagate.Diff.edit
  ]
*)
end)

module VerticalVersion = struct
  module Id = IVertical
  module Payload = VerticalDiff
  let name = "vertical"
  let t = `VerticalVersion
  let names = function
    | `Entities e -> MInstanceEntity.names e
    | `Propagate p -> MGroupPropagate.names p
end

module SavedVerticalVersion = Saved(VerticalVersion)

(* Communicating with the outside world ---------------------------------------------------- *)

let applies_to id versions = 
  List.filter (fun version -> List.mem id version # applies) versions

let applicable v = v # applies
let version v = v # version
let payload v = v # payload

type ('id,'payload) version = <
  applies : 'id list ;
  version : string ;
  payload : 'payload list
> ;;

let print_vertical_version = SavedVerticalVersion.print
let print_template_version = SavedTemplateVersion.print

class type entity_diffs = object
  method config  : MEntityConfig.Diff.t list 
  method   info  : MEntityInfo.Diff.t list 
  method fields  : MEntityFields.Diff.t list 
  method columns : MGroupColumn.Diff.t list 
  method join    : MJoinFields.Diff.t list
  method propagate : MGroupPropagate.Entity.Diff.t list
end

class type group_diffs = object 
  method join    : MJoinFields.Diff.t list
  method columns : MGroupColumn.Diff.t list 
  method propagate : MGroupPropagate.Entity.Diff.t list
end

let template_extract diffs = 
  let config, info, fields, columns, join, propagate = 
    List.fold_right begin fun e (config,info,fields,columns, join, propagate) ->
      match e with 
	| `Config    c -> (c :: config, info, fields, columns, join, propagate)
	| `Info      i -> (config, i :: info, fields, columns, join, propagate)
	| `Field     f -> (config, info, f :: fields, columns, join, propagate)
	| `Column    c -> (config, info, fields, c :: columns, join, propagate)
	| `Join      j -> (config, info, fields, columns, j :: join, propagate)
	| `Propagate p -> (config, info, fields, columns, join, p :: propagate)
    end diffs
      ([],[],[],[],[],[]) 
  in
  (object
    method config  = config
    method info    = info
    method fields  = fields
    method columns = columns
    method join    = join
    method propagate = propagate
   end)

let template_versions = 
  let get_all = 
    let! all = ohm $ SavedTemplateVersion.get_all in
    return (all :> (ITemplate.t, TemplateDiff.t) version list) 
  in
  try Run.eval (new CouchDB.init_ctx) get_all
    |> List.sort (fun a b -> compare a # version b # version) 
  with Http_client.Http_error(404,_) -> []

let last_template_version = 
  List.fold_left (fun acc v -> max acc v # version) "" template_versions
  
type vertical_diff = VerticalDiff.t

let vertical_versions = 
  let get_all = 
    let! all = ohm (SavedVerticalVersion.get_all) in
    return (all :> (IVertical.t, vertical_diff) version list) 
  in
  try Run.eval (new CouchDB.init_ctx) get_all
    |> List.sort (fun a b -> compare a # version b # version) 
  with Http_client.Http_error(404,_) -> []

let last_vertical_version = 
  List.fold_left (fun acc v -> max acc v # version) "" vertical_versions
  
module Admin = struct

  let overwrite_template_versions _ versions = 
    SavedTemplateVersion.overwrite versions last_template_version 

  let create_template_version _ ids diffs = 
    SavedTemplateVersion.save ids diffs

  let of_template _ template = 
    let! list = ohm $ SavedTemplateVersion.get_for template in
    return $ List.concat (List.map payload list)

  let overwrite_vertical_versions _ versions = 
    SavedVerticalVersion.overwrite versions last_vertical_version 

  let create_vertical_version _ ids diffs = 
    SavedVerticalVersion.save ids diffs

  let of_vertical _ vertical = 
    let! list = ohm $ SavedVerticalVersion.get_for vertical in
    return $ List.concat (List.map payload list)

end
