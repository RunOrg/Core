(* © 2012 RunOrg *)

type adlib = string

type infoField   = string * [ `LongText | `Text | `Url | `Date | `Address ]
type infoItem    = adlib option * infoField list
type infoSection = adlib * infoItem list

let infoField src kind = src, kind
let infoItem ?label fields = label, fields
let infoSection label items = label, items

type template = string
type template_data = {
  t_id : template ;
  t_old : string option ;
  t_name : adlib ;
  t_desc : adlib ;
  t_page : infoSection list ;
} 

let templates = ref []
let adlibs    = ref [] 

let adlib key (fr:string) = 
  try ignore (List.assoc key !adlibs) ; key
  with Not_found ->  adlibs := (key, fr) :: !adlibs ; key

let template id ?old ~kind ~name ~desc ~page () = 
  templates := {
    t_id   = id  ;
    t_old  = old ;
    t_name = adlib ("Template_"^id^"_Name") name ;
    t_desc = adlib ("Template_"^id^"_Desc") desc ;
    t_page = page ;
  } :: !templates ;
  id 

module Build = struct

  let adlibs_mli () =
    "include Ohm.Fmt.FMT with type t = \n  [ "
    ^ String.concat "\n  | " (List.map (fun (key,value) -> "`" ^ key) (!adlibs))
    ^ " ]\n\nval fr : t -> string"

  let adlibs_ml () = 
    "include Ohm.Fmt.Make(struct \n  type json t =\n    [ "
    ^ String.concat "\n    | " (List.map (fun (key,value) -> "`" ^ key) (!adlibs))
    ^ " ]\nend)\n\nlet fr = function "
    ^ String.concat "" (List.map (fun (key,value) -> 
      Printf.sprintf "\n  | `%s -> %S" key value) (!adlibs))
    ^ "\n"

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
end

let build dir = 
  let list = [
    "preConfig_Adlibs.mli", Build.adlibs_mli () ;
    "preConfig_Adlibs.ml" , Build.adlibs_ml  () ;
    "preConfig_TemplateId.ml", Build.templateId_ml () 
  ] in
  
  List.iter (fun (file,code) ->
    let out = open_out_bin (Filename.concat dir file) in
    output_string out code ;
    close_out out 
  ) list
