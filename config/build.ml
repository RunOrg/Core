(* © 2013 RunOrg *)

open Common

module Build = struct

  module Adlibs = struct

    let mli () =
      "include Ohm.Fmt.FMT with type t = \n  [ "
      ^ String.concat "\n  | " (List.map (fun (key,_) -> "`" ^ key) (!adlibs))
      ^ " ]\n\nval fr : t -> string\n\nval recover: string -> t option\n"
	
    let format () = 
      "include Ohm.Fmt.Make(struct \n  type json t =\n    [ "
      ^ String.concat "\n    | " (List.map (fun (key,_) -> "`" ^ key) (!adlibs))
      ^ " ]\nend)"

    let fr () = 
      "let fr = function "
      ^ String.concat "" (List.map (fun (key,(_,value)) -> 
	Printf.sprintf "\n  | `%s -> %S" key value) (!adlibs))      

    let recover () = 
      "let recover = function"
      ^ String.concat "" (List.map (fun (key,(old,_)) -> 
	match old with None -> "" | Some old -> 
	  Printf.sprintf "\n  | %S -> Some `%s" old key) (!adlibs))
      ^ "\n  | _ -> None\n"
	
    let ml () = 
      "open Ohm\n\n" 
      ^ format () 
      ^	"\n\n"
      ^ fr ()
      ^ "\n\n"
      ^ recover () 

  end

  module TemplateId = struct
      
    let ml () = 
      "module Events = PreConfig_TemplateId_Events\n"
      ^ "module Groups = PreConfig_TemplateId_Groups\n\n"

    let json_of_t templates = 
      "let json_of_t = function\n    | "
      ^ String.concat "\n    | " (List.map (fun t -> 
	Printf.sprintf "`%s -> Ohm.Json.String %S" t.t_id t.t_id) templates)
	
    let t_of_json templates = 
      "\n\n  let t_of_json = function\n    | "
      ^ String.concat "\n    | " (List.map (fun t -> 
	Printf.sprintf " Ohm.Json.String %S -> `%s" t.t_id t.t_id) templates)
      ^ "\n    | json -> Ohm.Json.parse_error \"template-id\" json"
	
    let fmt templates = 
      "include Ohm.Fmt.Make(struct \n  type t =\n    [ "
      ^ String.concat "\n    | " (List.map (fun t -> "`" ^ t.t_id) templates)
      ^ " ]"
      ^ "\n\n"
      ^ json_of_t templates
      ^ "\n\n"
      ^ t_of_json templates
      ^ "\nend)"
	
    let to_string templates = 
      "let to_string = function\n  | "
      ^ String.concat "\n  | " (List.map (fun t -> 
	Printf.sprintf "`%s -> %S" t.t_id t.t_id) templates)
	
    let of_string templates = 
      "let of_string = function\n  | "
      ^ String.concat "\n  | " (List.map (fun t -> 
	Printf.sprintf "%S -> Some `%s" t.t_id t.t_id) templates)
      ^ "\n  | _ -> None\n" 
	
    let id templates = 
      fmt templates
      ^ "\n\n"
      ^ to_string templates
      ^ "\n\n" 
      ^ of_string templates
	
	
    module Events = struct	
      let ml () = 
	let templates = List.filter (fun t -> t.t_kind = `Event) ! templates in
	id templates
    end 

    module Groups = struct
      let ml () = 
	let templates = List.filter (fun t -> t.t_kind = `Group) ! templates in
	id templates
    end 

  end

  module VerticalId = struct

    let format () = 
      "include Ohm.Fmt.Make(struct \n  type t =\n    [ "
      ^ String.concat "\n    | " (List.map (fun v -> "`" ^ v.v_id) (!verticals))
      ^ " ]\n\n  let json_of_t = function\n    | "
      ^ String.concat "\n    | " (List.map (fun v -> 
	Printf.sprintf "`%s -> Ohm.Json.String %S" v.v_id v.v_id) (!verticals))
      ^ "\n\n  let t_of_json = function\n    | "
      ^ String.concat "\n    | " (List.map (fun v -> 
	let old = match v.v_old with None -> "" | Some old -> Printf.sprintf " | Ohm.Json.String %S" old in
	Printf.sprintf " Ohm.Json.String %S%s -> `%s" v.v_id old v.v_id) (!verticals))
      ^ "\n    | json -> Ohm.Json.parse_error \"vertical-id\" json"
      ^ "\nend)"

    let to_string () = 
      "let to_string = function\n  | "
      ^ String.concat "\n  | " (List.map (fun v -> 
	Printf.sprintf "`%s -> %S" v.v_id v.v_id) (!verticals))      

    let of_string () = 
      "let of_string = function\n  | "
      ^ String.concat "\n  | " (List.map (fun v -> 
	let old = match v.v_old with None -> "" | Some old -> Printf.sprintf " | %S" old in
	Printf.sprintf "%S%s -> Some `%s" v.v_id old v.v_id) (!verticals))
      ^ "\n  | _ -> None\n" 

    let ml () = 
      format () 
      ^ "\n\n" 
      ^ to_string () 
      ^ "\n\n" 
      ^ of_string () 

  end


  module ProfileFormId = struct

    let format () = 
      "include Ohm.Fmt.Make(struct \n  type t =\n    [ "
      ^ String.concat "\n    | " (List.map (fun pf -> "`" ^ pf.pf_id) (!profileForms))
      ^ " ]\n\n  let json_of_t = function\n    | "
      ^ String.concat "\n    | " (List.map (fun pf -> 
	Printf.sprintf "`%s -> Ohm.Json.String %S" pf.pf_id pf.pf_id) (!profileForms))
      ^ "\n\n  let t_of_json = function\n    | "
      ^ String.concat "\n    | " (List.map (fun pf -> 
	Printf.sprintf " Ohm.Json.String %S -> `%s" pf.pf_id pf.pf_id) (!profileForms))
      ^ "\n    | json -> Ohm.Json.parse_error \"vertical-id\" json"
      ^ "\nend)"

    let to_string () = 
      "let to_string = function\n  | "
      ^ String.concat "\n  | " (List.map (fun pf -> 
	Printf.sprintf "`%s -> %S" pf.pf_id pf.pf_id) (!profileForms))      

    let of_string () = 
      "let of_string = function\n  | "
      ^ String.concat "\n  | " (List.map (fun pf -> 
	Printf.sprintf "%S -> Some `%s" pf.pf_id pf.pf_id) (!profileForms))
      ^ "\n  | _ -> None\n" 

    let ml () = 
      format () 
      ^ "\n\n"
      ^ to_string () 
      ^ "\n\n" 
      ^ of_string () 

  end

  let access = function
    | `Registered -> "`Registered"
    | `Viewers    -> "`Viewers"
    | `Managers   -> "`Managers"

  module ProfileForm = struct

    let name () = 
      "let name = function\n  | "
      ^ String.concat "\n  | " 
	(List.map (fun pf -> Printf.sprintf "`%s -> `%s" pf.pf_id pf.pf_name) (!profileForms))

    let subtitle () =
      "let subtitle = function\n  | "
      ^ String.concat "\n  | " (List.map (fun pf -> Printf.sprintf "`%s -> %s" pf.pf_id 
	(match pf.pf_subtitle with Some s -> "Some `"^s | None -> "None")) (!profileForms))       
      
    let comment () =
      "let comment = function\n  | "
      ^ String.concat "\n  | " 
	(List.map 
	   (fun pf -> Printf.sprintf "`%s -> %s" pf.pf_id (if pf.pf_comment then "true" else "false"))
	   (!profileForms))
	
    let field j = 
      Printf.sprintf "(object
      method name = %S
      method label = `PreConfig `%s
      method required = %s
      method edit = %s
    end)"
	j.j_name 
	j.j_label 
	(if j.j_req then "true" else "false") 
	(match j.j_type with 
	  | `Textarea -> "`Textarea"
	  | `Checkbox -> "`Checkbox"
	  | `LongText -> "`LongText"
	  | `Date     -> "`Date"
	  | `PickOne  l -> Printf.sprintf "`PickOne [%s]"
	    (String.concat ";" (List.map (fun l -> "`PreConfig `" ^ l) l))
	  | `PickMany l -> Printf.sprintf "`PickMany [%s]"
	    (String.concat ";" (List.map (fun l -> "`PreConfig `" ^ l) l)))

    let form_fields pf = 
      Printf.sprintf "`%s -> [\n    %s ]" pf.pf_id 
	(String.concat ";\n    " (List.map field pf.pf_fields))	

    let fields () = 
      "let fields = function\n  | "
      ^ String.concat "\n  | " (List.map form_fields  (!profileForms))
	
    let ml () = 
      name () 
      ^ "\n\n"
      ^ subtitle () 
      ^ "\n\n"
      ^ comment () 
      ^ "\n\n"
      ^ fields () 
  end

  module Template = struct

    let ml () = 
      "module Events = PreConfig_Template_Events\n"
      ^ "module Groups = PreConfig_Template_Groups\n\n"

    let group templates = 
      "let group = function\n  | "
      ^ String.concat "\n  | " 
	(List.map 
	   (fun t -> 
	     Printf.sprintf "`%s -> %s" t.t_id (match t.t_group with 
	       | None -> "None"
	       | Some (valid,read) -> Printf.sprintf 
		 "Some (object method validation = %s method read = %s end)"
		 (match valid with `Manual -> "`Manual" | `None -> "`None")
		 (access read))) 
	   templates)

    let field j = 
      Printf.sprintf 
	"(object
      method name = %S
      method label = `label `%s
      method required = %s
      method edit = %s
    end)"
	j.j_name 
	j.j_label 
	(if j.j_req then "true" else "false") 
	(match j.j_type with 
	  | `Textarea -> "`Textarea"
	  | `Checkbox -> "`Checkbox"
	  | `LongText -> "`LongText"
	  | `Date     -> "`Date"
	  | `PickOne  l -> Printf.sprintf "`PickOne [%s]"
	    (String.concat ";" (List.map (fun l -> "`label `" ^ l) l))
	  | `PickMany l -> Printf.sprintf "`PickMany [%s]"
	    (String.concat ";" (List.map (fun l -> "`label `" ^ l) l)))
	
    let join templates = 
      "let join = function\n  | "
      ^ String.concat "\n  | " (List.map (fun t -> 
	Printf.sprintf "`%s -> [\n    %s ]" t.t_id 
	  (String.concat ";\n    " (List.map field t.t_join))) templates)

    let name templates = 
      "let name = function\n  | "
      ^ String.concat "\n  | " (List.map (fun t -> Printf.sprintf "`%s -> `%s" t.t_id t.t_name) templates)
	
    let desc templates = 
      "let desc = function\n  | "
      ^ String.concat "\n  | " (List.map (fun t -> Printf.sprintf "`%s -> %s" t.t_id 
	(match t.t_desc with Some s -> "Some `"^s | None -> "None")) templates)

    let column c = 
      Printf.sprintf 
	"MAvatarGridColumn.({ label = `label `%s ; view = `%s ; eval = %s })"
	c.c_label
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
	      | `Field s -> Printf.sprintf "`Field %S" s))
	
    let columns templates = 	
      "\n\nlet columns iid gid = function\n  | "
      ^ String.concat "\n  | " (List.map (fun t -> 
	Printf.sprintf "`%s -> [\n   %s ]" t.t_id
	  (String.concat ";\n    " (List.map column t.t_cols))) templates)
				
    module Groups = struct

      let propagate templates = 
	"let propagate = function\n  | "
	^ String.concat "\n  | " (List.map (fun t -> Printf.sprintf "`%s -> [%s]" t.t_id 
	  (match t.t_propg with None -> "" | Some g -> Printf.sprintf "%S" g)) templates)

      let ml () = 
	let templates = List.filter (fun t -> t.t_kind = `Group) !templates in 
	group templates
	^ "\n\n"
	^ join templates 
	^ "\n\n"
	^ name templates
	^ "\n\n" 
	^ desc templates
	^ "\n\n"
	^ propagate templates
	^ "\n\n"
	^ columns templates 
	  
    end 

    module Events = struct

      let satellite templates name f = 
	"let " ^ name  ^ " = function\n  | "
	^ String.concat "\n  | " (List.map (fun t -> 
	  Printf.sprintf "`%s -> %s" t.t_id (match f t with 
	    | None -> "None"
	    | Some (read,post) -> Printf.sprintf 
	      "Some (object method read = %s method post = %s end)"
	      (access read) (access post))) templates)

      let wall templates = 
	satellite templates "wall" (fun t -> t.t_wall)
	  
      let folder templates = 
	satellite templates "folder" (fun t -> t.t_folder) 
	  
      let album templates = 
	satellite templates "album" (fun t -> t.t_album) 

      let ml () = 
	let templates = List.filter (fun t -> t.t_kind = `Event) !templates in 
	group templates 
	^ "\n\n" 
	^ wall templates
	^ "\n\n"
	^ folder templates
	^ "\n\n"
	^ album templates
	^ "\n\n"
	^ join templates
	^ "\n\n"
	^ name templates
	^ "\n\n"
	^ desc templates
	^ "\n\n"
	^ columns templates

    end	  

  end 

  module Vertical = struct

    let templates kind vertical = 
      Printf.sprintf "`%s -> [%s]" vertical.v_id
	(String.concat ";" 
	   (List.map (Printf.sprintf "`%s") 
	      (List.filter begin fun template -> 
		try let data = List.find (fun t -> t.t_id = template) (!templates) in
		    data.t_kind = kind
		with Not_found -> false
	      end vertical.v_tmpl)))
  
    let events () = 
      "let events = function\n  | "
      ^ String.concat "\n  | " (List.map (templates `Event) (!verticals))      	

    let groups () = 
      "let groups = function\n  | "
      ^ String.concat "\n  | " (List.map (templates `Group) (!verticals))      

    let create () = 
      "let create = function\n  | "
      ^ String.concat "\n  | " begin
	List.map begin fun (vertical) -> 	  
	  Printf.sprintf "`%s -> [%s]" vertical.v_id
	    (String.concat ";" 
	       (BatList.filter_map begin fun i -> 
		 match template_by_id i.i_tmpl with None -> None | Some t -> 
		   match t.t_kind with 
		     | `Group -> Some (
		       Printf.sprintf "`%s,`%s" 
			 i.i_tmpl i.i_name
		     )
		     | _ -> None
	       end vertical.v_init))	    
	end (!verticals)
      end

    let profileForms () = 
      "let profileForms = function\n  | "
      ^ String.concat "\n  | " begin
	List.map begin fun (vertical) -> 
	  Printf.sprintf "`%s -> [%s]" vertical.v_id
	    (String.concat ";" 
	       (List.map (Printf.sprintf "`%s") vertical.v_pfs))
	end (!verticals)
      end

    let list () = 
      "  let list = [\n    "
      ^ String.concat " ;\n    "  begin
	BatList.mapi begin fun i (name,verticals) -> 
	  Printf.sprintf 
	    "(object
      method id = \"cat%d\"
      method name = `%s
      method items = [
        %s]
    end)" 
	    i name (String.concat ";\n        " begin
	      BatList.mapi begin fun j (vertical,name,desc) -> 
		Printf.sprintf
		  "(object
          method value = \"%d-%d\"
          method name = `%s
          method desc = %s
        end)"
		  i j name (match desc with 
		    | None -> "None"
		    | Some desc -> "Some `" ^ desc)
	      end verticals
	    end)
	end (!the_catalog) 		
      end
      ^ " ]"

    let vertical () = 
      "  let vertical = function\n    | "
      ^ String.concat "\n    | "  begin
	let list = 
	  BatList.mapi begin fun i (_,verticals) -> 
	    BatList.mapi begin fun j (vertical,name,desc) -> 
	      Printf.sprintf "\"%d-%d\" -> Some `%s" i j vertical 
	    end verticals
	  end (!the_catalog)
	in	
	List.concat list	  
      end
      ^ "\n    | _ -> None"      

    let init () = 
      "  let init = function\n    | "
      ^ String.concat "\n    | "  begin
	
	let found = 
	  let hash = Hashtbl.create 50 in
	  fun k -> try Hashtbl.find hash k ; true with Not_found -> Hashtbl.add hash k () ; false
	in
	
	let list = 
	  BatList.mapi begin fun i (_,verticals) -> 
	    BatList.mapi begin fun j (vertical,name,desc) -> 
	      if found vertical then [] else 
		[ Printf.sprintf "`%s -> Some \"%d-%d\"" vertical i j ] 
	    end verticals
	  end (!the_catalog)
	in
	
	List.concat (List.concat list)
 	  
      end
      ^ "\n    |  _ -> None"
	
    let catalog () = 
      "module Catalog = struct\n\n"
      ^ list () 
      ^ "\n\n"
      ^ vertical () 
      ^ "\n\n"
      ^ init () 
      ^ "\n\nend"
	
    let ml () =   
      events () 
      ^ "\n\n"
      ^ groups () 
      ^ "\n\n"
      ^ create () 
      ^ "\n\n"
      ^ profileForms () 
      ^ "\n\n"
      ^ catalog () 
	
  end

  module DMS = DMS.Build

end

let build dir = 
  let list = Build.([
    "Adlibs.mli", Adlibs.mli ;
    "Adlibs.ml" , Adlibs.ml  ;
    "TemplateId_Events.ml", TemplateId.Events.ml ;
    "TemplateId_Groups.ml", TemplateId.Groups.ml ;
    "TemplateId.ml", TemplateId.ml ;
    "VerticalId.ml", VerticalId.ml ;
    "Template_Events.ml", Template.Events.ml ;  
    "Template_Groups.ml", Template.Groups.ml ;  
    "Template.ml", Template.ml ;
    "Vertical.ml", Vertical.ml ;
    "ProfileFormId.ml", ProfileFormId.ml ;
    "ProfileForm.ml", ProfileForm.ml ;
    "DMS.ml", DMS.ml ; 
  ]) in
  
  List.iter (fun (file,code) ->
    let out = open_out_bin (Filename.concat dir ("preConfig_" ^ file)) in
    output_string out (code ()) ;
    close_out out 
  ) list
