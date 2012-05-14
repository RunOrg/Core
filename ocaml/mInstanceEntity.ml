(* © 2012 MRunOrg *)

open Ohm

module Update = Fmt.Make(struct
   
(*
  let edit = JoyA.obj [
    JoyA.field "name" ~label:"Nom" (JoyA.string ~autocomplete:MPreConfigNames.entity ()) ;
    JoyA.field "title" ~label:"Etiquette" (JoyA.optional (JoyA.string ~autocomplete:MPreConfigNames.i18n ())) ;
    JoyA.field "public" ~label:"Public" (JoyA.optional JoyA.bool) ;
    JoyA.field "draft" ~label:"Brouillon" (JoyA.optional JoyA.bool) ;
    JoyA.field "data" ~label:"Champs" (JoyA.dict (JoyA.string ())) ;
  ]
*)

  type json t = 
  <
    name : string ;
    title : string option ;
    public : bool option ;
    draft : bool option ;
    data : (string * string) assoc
  >
end)

type 'a update =  
       ?draft:bool 
    -> ?public:bool 
    -> ?name:[`label of string | `text of string] option 
    -> ?data:(string * Json_type.t) list
    -> ?config:MEntityConfig.Diff.t list
    -> unit 
    -> 'a

type changes = {
  draft  : bool option ;
  name   : string option ;
  public : bool option ;
  data   : (string * string) list ;
  config : MEntityConfig.Diff.t list
}

let update changes (f:'a update) = 
  let default = {
    draft  = None ;
    public = None ;
    name   = None ;
    data   = [] ;
    config = []
  } in  
  let args = List.fold_left begin fun args what ->
    match what with 
      | `Update u -> let args = 
		       if u # draft <> None then { args with draft = u # draft } 
		       else args 
		     in
		     let args = 
		       if u # public <> None then { args with public = u # public } 
		       else args
		     in
		     let args = 
		       if u # title <> None then { args with name = u # title } 
		       else args
		     in
		     let args = 
		       { args with data = List.fold_left 
			   (fun data (k,v) -> ListAssoc.replace k v data) args.data (u # data)
		       }
		     in
		     args
      | `Config c -> { args with config = args.config @ c # diffs }
  end default changes in
  f ?draft:(args.draft)
    ?public:(args.public)
    ?name:(BatOption.map (fun t -> Some (`label t)) args.name)
    ~data:(List.map (fun (k,v) -> k, Json_type.Build.string v) args.data)
    ~config:(args.config)
    ()
      
module Create = Fmt.Make(struct
   
(*
  let edit = JoyA.obj [
    JoyA.field "name" ~label:"Nom" (JoyA.string ~autocomplete:MPreConfigNames.entity ()) ;
    JoyA.field "template" ~label:"Modèle" 
      (JoyA.string ~autocomplete:MPreConfigNames.template ()) ;
  ]
*)

  type json t = 
  <
    name : string ;
    template : ITemplate.t 
  >
end)

module Config = Fmt.Make(struct

  module EntityConfigDiff = MEntityConfig.Diff

(*
  let edit = JoyA.obj [
    JoyA.field "name" ~label:"Nom" (JoyA.string ~autocomplete:MPreConfigNames.entity ()) ;
    JoyA.field "diffs" ~label:"Modifications" 
      (JoyA.array MEntityConfig.Diff.edit) ;
  ]
*)

  type json t = 
  <
    name   : string ;
    diffs  : EntityConfigDiff.t list
  >

end)

module Diff = Fmt.Make(struct
   
(*
  let edit = JoyA.variant [
    JoyA.alternative ~label:"Créer une entité" ~content:Create.edit "Create" ;
    JoyA.alternative ~label:"Modifier une entité" ~content:Update.edit "Update" ;
    JoyA.alternative ~label:"Configurer une entité" ~content:Config.edit "Config"
  ]
*)

  type json t = 
    [ `Create of Create.t
    | `Update of Update.t 
    | `Config of Config.t ]

end)

let names = function 
  | `Create c -> [ MPreConfigNames.entity, (c # name) ]
  | `Update _ -> []
  | `Config c -> ( MPreConfigNames.entity, (c # name) ) ::
    List.concat (List.map MEntityConfig.names (c # diffs)) 

