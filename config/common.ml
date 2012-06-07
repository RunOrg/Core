(* © 2012 RunOrg *)

type adlib = string

type infoField   = string * [ `LongText | `Text | `Url | `Date | `Address ]
type infoItem    = adlib option * infoField list
type infoSection = adlib * infoItem list

let infoField src kind = src, kind
let infoItem ?label fields = label, fields
let infoSection label items = label, items

type groupConfig = [`Group|`Event] * [`Manual|`None] * [`Viewers|`Registered|`Managers] * [`Yes|`No]
type collabConfig = [`Viewers|`Registered|`Managers] * [`Viewers|`Registered|`Managers] 

type join = { 
  j_name  : string ;
  j_label : adlib ;
  j_req   : bool ;
  j_type  : [ `Checkbox | `Textarea | `LongText | `Date | `PickOne of adlib list | `PickMany of adlib list ]
}

let join ~name ~label ?(required=false) typ = {
  j_name  = name ;
  j_label = label ;
  j_req   = required ;
  j_type  = typ
} 

type field = {
  f_label : adlib ;
  f_help  : adlib option ;
  f_mean  : [`Summary | `Picture | `Description | `Date | `Location | `Enddate ] option ;
  f_edit  : [ `Textarea | `LongText | `Picture | `Date ] ;
  f_key   : string ;
  f_req   : bool 
}

let field ~label ?help ?mean ?(required=false) edit key = {
  f_label = label ;
  f_help  = help ;
  f_mean  = mean ; 
  f_req   = required ;
  f_edit  = edit ;
  f_key   = key 
}

type column = { 
  c_show  : bool ;
  c_sort  : bool ;
  c_label : adlib ;
  c_view  : [ `Text | `Date | `DateTime | `Status | `PickOne | `Checkbox ] ;
  c_eval  : [ `Profile of [ `Zipcode | `Birthdate | `Firstname | `Lastname | `Email ] 
	    | `Self of [ `Status | `Date | `Field of string ] ] 
}

let column ?(show=false) ?(sort=false) ~label ~view eval = {
  c_show  = show ;
  c_sort  = sort ;
  c_label = label ;
  c_view  = view ;
  c_eval  = eval
}

type template = string
type template_data = {
  t_id : template ;
  t_old : string option ;
  t_name : adlib ;
  t_desc : adlib ;
  t_join : join list ;
  t_kind : [ `Group | `Subscription | `Event | `Album | `Forum | `Course | `Poll ] ;  
  t_page : infoSection list ;
  t_group  : groupConfig option ;
  t_wall   : collabConfig option ;
  t_folder : collabConfig option ;
  t_album  : collabConfig option ;
  t_fields : field list ;
  t_cols   : column list ;
  t_propg  : string option 
} 

let templates = ref []
let adlibs    = ref [] 

let adlib key ?(old:string option) (fr:string) = 
  let key = match key.[0] with '0' .. '9' -> "_" ^ key | _ -> key in
  try ignore (List.assoc key !adlibs) ; key
  with Not_found ->  adlibs := (key, (old,fr)) :: !adlibs ; key

let groupConfig ~semantics ~validation ~read ~grant = semantics, validation, read,  grant
let wallConfig ~read ~post = read, post
let folderConfig = wallConfig
let albumConfig = wallConfig

let template id ?old ~kind ~name ~desc ?propagate 
    ?(columns=[]) ?(fields=[]) ?(join=[]) ?group ?wall ?folder ?album ~page () = 
  templates := {
    t_id     = id  ;
    t_old    = old ;
    t_kind   = kind ;
    t_name   = adlib ("Template_"^id^"_Name") name ;
    t_desc   = adlib ("Template_"^id^"_Desc") desc ;
    t_join   = join ;
    t_page   = page ;
    t_group  = group ;
    t_wall   = wall ;
    t_folder = folder ;
    t_album  = album ;
    t_fields = fields ;
    t_cols   = columns ;
    t_propg  = propagate
  } :: !templates ;
  id 

module Build = struct

  let adlibs_mli () =
    "include Ohm.Fmt.FMT with type t = \n  [ "
    ^ String.concat "\n  | " (List.map (fun (key,_) -> "`" ^ key) (!adlibs))
    ^ " ]\n\nval fr : t -> string\n\nval recover: string -> t option\n"

  let adlibs_ml () = 
    "open Ohm\ninclude Ohm.Fmt.Make(struct \n  type json t =\n    [ "
    ^ String.concat "\n    | " (List.map (fun (key,_) -> "`" ^ key) (!adlibs))
    ^ " ]\nend)\n\nlet fr = function "
    ^ String.concat "" (List.map (fun (key,(_,value)) -> 
      Printf.sprintf "\n  | `%s -> %S" key value) (!adlibs))
    ^ "\n\nlet recover = function"
    ^ String.concat "" (List.map (fun (key,(old,_)) -> 
      match old with None -> "" | Some old -> 
	Printf.sprintf "\n  | %S -> Some `%s" old key) (!adlibs))
    ^ "\n  | _ -> None\n"

  let templateId_ml () = 
    "include Ohm.Fmt.Make(struct \n  type t =\n    [ "
    ^ String.concat "\n    | " (List.map (fun t -> "`" ^ t.t_id) (!templates))
    ^ " ]\n\n  let json_of_t = function\n    | "
    ^ String.concat "\n    | " (List.map (fun t -> 
      Printf.sprintf "`%s -> Ohm.Json.String %S" t.t_id t.t_id) (!templates))
    ^ "\n\n  let t_of_json = function\n    | "
    ^ String.concat "\n    | " (List.map (fun t -> 
      let old = match t.t_old with None -> "" | Some old -> Printf.sprintf " | Ohm.Json.String %S" old in
      Printf.sprintf " Ohm.Json.String %S%s -> `%s" t.t_id old t.t_id) (!templates))
    ^ "\n    | json -> Ohm.Json.parse_error \"template-id\" json"
    ^ "\nend)\n\nlet to_string = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> %S" t.t_id t.t_id) (!templates))
    ^ "\n\nlet of_string = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      let old = match t.t_old with None -> "" | Some old -> Printf.sprintf " | %S" old in
      Printf.sprintf "%S%s -> Some `%s" t.t_id old t.t_id) (!templates))
    ^ "\n  | _ -> None\n" 

  let access = function
    | `Registered -> "`Registered"
    | `Viewers    -> "`Viewers"
    | `Managers   -> "`Managers"

  let template_ml () = 

    (* Basic configuration data ============================================================================= *)
    "let group = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> %s" t.t_id (match t.t_group with 
	| None -> "None"
	| Some (semantics,valid,read,grant) -> Printf.sprintf 
	  "Some (object method semantics = %s method validation = %s method read = %s method grant = %s end)"
	  (match semantics with `Event -> "`Event" | `Group -> "`Group")
	  (match valid with `Manual -> "`Manual" | `None -> "`None")
	  (access read)
	  (match grant with `Yes -> "`Yes" | `No -> "`No"))) (!templates))
    ^ "\n\nlet wall = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> %s" t.t_id (match t.t_wall with 
	| None -> "None"
	| Some (read,post) -> Printf.sprintf 
	  "Some (object method read = %s method post = %s end)"
	  (access read) (access post))) (!templates))
    ^ "\n\nlet folder = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> %s" t.t_id (match t.t_folder with 
	| None -> "None"
	| Some (read,post) -> Printf.sprintf 
	  "Some (object method read = %s method post = %s end)"
	  (access read) (access post))) (!templates))
    ^ "\n\nlet album = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> %s" t.t_id (match t.t_album with 
	| None -> "None"
	| Some (read,post) -> Printf.sprintf 
	  "Some (object method read = %s method post = %s end)"
	  (access read) (access post))) (!templates))

      (* Join form fields =================================================================================== *)
    ^ "\n\nlet join = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> [\n    %s ]" t.t_id 
	(String.concat ";\n    " 
	   (List.map (fun j -> Printf.sprintf 
	     "(object\n      method name = %S\n      method label = `label `%s\n      method valid = [%s]\n      method edit = %s\n    end)"
	     j.j_name j.j_label (if j.j_req then "`required" else "") 
	     (match j.j_type with 
	       | `Textarea -> "`Textarea"
	       | `Checkbox -> "`Checkbox"
	       | `LongText -> "`LongText"
	       | `Date     -> "`Date"
	       | `PickOne  l -> Printf.sprintf "`PickOne [%s]"
		 (String.concat ";" (List.map (fun l -> "`label `" ^ l) l))
	       | `PickMany l -> Printf.sprintf "`PickMany [%s]"
		 (String.concat ";" (List.map (fun l -> "`label `" ^ l) l)))
	    ) t.t_join)
	)) (!templates))

      (* The kind of a template ============================================================================= *)
    ^ "\n\nlet kind = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> `%s" t.t_id (match t.t_kind with 
	| `Group -> "Group"
	| `Subscription -> "Subscription"
	| `Event -> "Event"
	| `Forum -> "Forum"
	| `Course -> "Course"
	| `Poll -> "Poll"
	| `Album -> "Album")) (!templates))

      (* The name (adlib) of the template =================================================================== *)
    ^ "\n\nlet name = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> Printf.sprintf "`%s -> `%s" t.t_id t.t_name) (!templates))

      (* The name (adlib) of the template =================================================================== *)
    ^ "\n\nlet propagate = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> Printf.sprintf "`%s -> [%s]" t.t_id 
      (match t.t_propg with None -> "" | Some g -> Printf.sprintf "%S" g)) (!templates))

      (* Initial grid columns =============================================================================== *)
    ^ "\n\nlet columns iid gid = function\n  | "
    ^ String.concat "\n  | " (List.map (fun t -> 
      Printf.sprintf "`%s -> [\n   %s ]" t.t_id
	(String.concat ";\n    "
	   (List.map (fun c -> Printf.sprintf 
	     "MAvatarGridColumn.({ label = `label `%s ; show = %s ; view = `%s ; eval = %s })"
	     c.c_label (if c.c_show then "true" else "false") 
	     (match c.c_view with 
	       | `Text -> "Text"
	       | `Date -> "Date"
	       | `DateTime -> "DateTime"
	       | `Status -> "Status"
	       | `PickOne -> "PickOne"
	       | `Checkbox -> "Checkbox")
	     (match c.c_eval with 
	       | `Profile sub -> Printf.sprintf "`Profile (iid,%s)"
		 (match sub with 
		   | `Firstname -> "`Firstname"
		   | `Lastname  -> "`Lastname"
		   | `Zipcode   -> "`Zipcode"
		   | `Birthdate -> "`Birthdate"
		   | `Email     -> "`Email")
	       | `Self sub -> Printf.sprintf "`Group (gid,%s)"
		 (match sub with 
		   | `Status  -> "`Status"
		   | `Date    -> "`Date"
		   | `Field s -> Printf.sprintf "`Field %S" s))) t.t_cols))
    ) (!templates))
      
      (* The field name, by meaning ========================================================================= *)
    ^ "\n\nmodule Meaning = struct\n\n"
    ^ String.concat "\n\n" begin
      List.map (fun (mean,meanstr) -> 
	Printf.sprintf "  let %s = function\n    | %s" meanstr 
	  (String.concat "\n    | " (List.map (fun t -> 
	    "`" ^ t.t_id ^ " -> " ^ begin 
	      try let f = List.find (fun f -> f.f_mean = Some mean) t.t_fields in
		  Printf.sprintf "Some %S" f.f_key
	      with Not_found -> "None"
	    end
	   ) (!templates)))
      ) [ `Description, "description" ;
	  `Date,        "date" ;
	  `Summary,     "summary" ;
	  `Enddate,     "endDate" ;
	  `Location,    "location" ;
	  `Picture,     "picture" ] 
    end
    ^ "\n\nend"
end

let build dir = 
  let list = [
    "preConfig_Adlibs.mli", Build.adlibs_mli () ;
    "preConfig_Adlibs.ml" , Build.adlibs_ml  () ;
    "preConfig_TemplateId.ml", Build.templateId_ml () ;
    "preConfig_Template.ml", Build.template_ml () 
  ] in
  
  List.iter (fun (file,code) ->
    let out = open_out_bin (Filename.concat dir file) in
    output_string out code ;
    close_out out 
  ) list
