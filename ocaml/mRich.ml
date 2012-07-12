(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type doc = 
  [ `TEXT of string
  | `I of doc
  | `B of doc
  | `BR
  | `P of doc
  | `UL of doc list
  | `OL of doc list
  | `INDENT of doc
  ] list

module Rich = Fmt.Make(struct

  type t = doc 

  let rec inline_to_json = function 
    | `TEXT   s      -> Json.String s
    | `B      inline -> Json.Object [ "b", Json.of_list inline_to_json inline ] 
    | `I      inline -> Json.Object [ "i", Json.of_list inline_to_json inline ] 
    | `P      inline -> Json.Object [ "p", Json.of_list inline_to_json inline ]
    | `INDENT inline -> Json.Object [ "d", Json.of_list inline_to_json inline ]
    | `UL     list   -> Json.Object [ "u", Json.of_list (Json.of_list inline_to_json) list ]
    | `OL     list   -> Json.Object [ "o", Json.of_list (Json.of_list inline_to_json) list ]
    | `BR            -> Json.Array []
  
  let rec json_to_inline = function 
    | Json.String s -> `TEXT s
    | Json.Array [] -> `BR
    | Json.Object [ "b", json ] -> `B (Json.to_list json_to_inline json) 
    | Json.Object [ "i", json ] -> `I (Json.to_list json_to_inline json) 
    | Json.Object [ "p", json ] -> `P (Json.to_list json_to_inline json) 
    | Json.Object [ "d", json ] -> `INDENT (Json.to_list json_to_inline json) 
    | Json.Object [ "u", json ] -> `UL (Json.to_list (Json.to_list json_to_inline) json) 
    | Json.Object [ "o", json ] -> `OL (Json.to_list (Json.to_list json_to_inline) json) 
    | _ -> raise (Json.Error "Incorrect format for MRich.t") 

  let json_of_t = Json.of_list inline_to_json
  let t_of_json = Json.to_list json_to_inline

end)

include Rich

let to_html (doc:doc) html =

  let b = html.Html.html in 

  let rec recprint = function 
    | `TEXT   t -> Html.esc t html
    | `BR       -> Buffer.add_string b "<br/>" 
    | `B l      -> Buffer.add_string b "<b>" ; List.iter recprint l ; Buffer.add_string b "</b>"
    | `I l      -> Buffer.add_string b "<i>" ; List.iter recprint l ; Buffer.add_string b "</i>"
    | `P l      -> Buffer.add_string b "<p>" ; List.iter recprint l ; Buffer.add_string b "</p>"
    | `INDENT l -> Buffer.add_string b "<div style='margin-left: 40px'>" ;
                   List.iter recprint l ;
		   Buffer.add_string b "</div>"
    | `UL l     -> Buffer.add_string b "<ul>" ;
                   List.iter (fun l -> Buffer.add_string b "<li>" ;
		                       List.iter recprint l ;
				       Buffer.add_string b "</li>") l ;
		   Buffer.add_string b "</ul>"
    | `OL l     -> Buffer.add_string b "<ol>" ;
                   List.iter (fun l -> Buffer.add_string b "<li>" ;
		                       List.iter recprint l ;
				       Buffer.add_string b "</li>") l ;
		   Buffer.add_string b "</ol>"
  in

  List.iter recprint doc

let whitespace = 
  Str.regexp "^\\([ \t\r\n]\\|\194\160\\|&nbsp;\\|&emsp;\\|&ensp;\\)*$"

let indent = 
  Str.regexp "margin-left *: *[1-9][0-9]*px"

let bold = 
  Str.regexp "font-weight *: *bold"

let italic = 
  Str.regexp "font-style *: *italic"

let empty string = 
  Str.string_match whitespace string 0 && Str.match_end () = String.length string

let is_indent attrs = 
  try let style = List.assoc "style" attrs in 
      ignore (Str.search_forward indent style 0) ;
      true
  with _ -> false

let is_bold attrs = 
  try let style = List.assoc "style" attrs in 
      ignore (Str.search_forward bold style 0) ;
      true
  with _ -> false

let is_italic attrs = 
  try let style = List.assoc "style" attrs in 
      ignore (Str.search_forward italic style 0) ;
      true
  with _ -> false

let length doc = 

  let rec total acc doc = 
    List.fold_left (fun acc node -> 
      match node with 
	| `TEXT t -> acc + String.length t
	| `P l | `B l | `I l | `INDENT l -> total acc l 
	| `BR -> acc 
	| `UL l | `OL l -> List.fold_left total acc l     
    ) acc doc
  in

  total 0 doc

let parse string = 

  let lexbuf = Lexing.from_string string in 

  let unescape str = 
    let amp     = Str.regexp "&amp;" in
    let lt      = Str.regexp "&lt;" in
    let str     = Str.global_replace lt  "<" str in
    let str     = Str.global_replace amp "&" str in
    str
  in

  (* STEP 1 : parse the document *)

  let doclist = Nethtml.parse_document ~dtd:Nethtml.relaxed_html40_dtd lexbuf in
  
  (* STEP 2 : extract a dirty element tree. *)

  let rec block depth doclist =
    if depth = 50 then [] else
      let depth = depth + 1 in
      List.concat $ List.map Nethtml.(function
	| Data text -> if empty text then [] else [`TEXT (unescape text)]
	| Element (("b"|"strong"),_,l) -> [`B (inline depth l)]
	| Element (("i"|"em"),_,l) -> [`I (inline depth l)] 
	| Element (("br"|"hr"),_,l) -> if l = [] then [`BR] else `BR :: block depth l
	| Element ("span",a,l) when is_italic a -> [`I (inline depth l)] 
	| Element ("span",a,l) when is_bold a -> [`B (inline depth l)] 
	| Element ("ul",_,l) -> [`UL (list depth l)]
	| Element ("ol",_,l) -> [`OL (list depth l)]
	| Element ("p",a,l) -> if is_indent a then [`INDENT [`P (inline depth l)]] else [`P (inline depth l)]   
	| Element ("div",a,l) -> if is_indent a then [`INDENT (block depth l)] else block depth l 
	| Element (("script"|"style"),_,_) -> []
	| Element (k,_,l) -> block depth l) doclist
  
  and inline depth doclist = 
    if depth = 50 then [] else
      let depth = depth + 1 in
      List.concat $ List.map Nethtml.(function
	| Data text -> if empty text then [] else [`TEXT (unescape text)]
	| Element (("b"|"strong"),_,l) -> [`B (inline depth l)]
	| Element (("i"|"em"),_,l) -> [`I (inline depth l)] 
	| Element ("span",a,l) when is_italic a -> [`I (inline depth l)] 
	| Element ("span",a,l) when is_bold a -> [`B (inline depth l)] 
	| Element (("br"|"hr"),_,l) -> if l = [] then [`BR] else `BR :: block depth l
	| Element (k,_,l) -> block depth l) doclist
  
  and list depth doclist = 
    if depth = 50 then [] else
      let depth = depth + 1 in 
      BatList.filter_map Nethtml.(function
	| Element ("li",_,l) -> Some (block depth l)
	| _ -> None) doclist

  in

  let blocks = block 0 doclist in 

  (* STEP 3 : clean up the extracted blocks *)

  let rec clean accum current list =

    let mkp () = 
      if length current = 0 then accum else `P (List.rev current) :: accum
    in
	  
    let recurse what tail = 
      let accum = mkp () in
      clean (what :: accum) [] tail  
    in

    match list with 
      | `UL l :: t -> recurse (`UL (List.map (clean [] []) l)) t
      | `OL l :: t -> recurse (`OL (List.map (clean [] []) l)) t
      | `P  l :: t -> if length l = 0 then clean accum current t else recurse (`P l) t 
      | `B  l :: t -> clean accum (`B l :: current) t
      | `I  l :: t -> clean accum (`I l :: current) t 
      | `INDENT l :: t -> recurse (`INDENT (clean [] [] l)) t
      | `TEXT s :: t -> clean accum (`TEXT s :: current) t 
      | `BR :: `BR :: t -> let accum = mkp () in
			   clean accum [] t
      | `BR :: t -> if length current = 0 then clean accum current t else clean accum (`BR :: current) t 
      | [] -> let accum = mkp () in List.rev accum 
  in

  clean [] [] blocks

module OrText = struct

  include Fmt.Make(struct

    type t = [ `Rich of Rich.t | `Text of string ] 

    let t_of_json = function 
      | Json.String s -> `Text s
      | json -> `Rich (Rich.of_json json) 

    let json_of_t = function 
      | `Text s -> Json.String s
      | `Rich r -> Rich.to_json r 

  end)

  let raw_html str = 
    let amp     = Str.regexp "&" in
    let lt      = Str.regexp "<" in
    let parskip = Str.regexp "\n[ \t\n]*\n" in
    let break   = Str.regexp "\n" in
    let str     = Str.global_replace amp "&amp;" str in
    let str     = Str.global_replace lt  "&lt;"  str in
    let paragraphs = Str.split parskip str in 
    let paragraphs = List.filter (fun s -> s <> "") paragraphs in
    let paragraphs = List.map (Str.global_replace break "<br/>") paragraphs in
    let html = "<p>" ^ String.concat "</p><p>" paragraphs ^ "</p>" in
    html

  let to_html = function
    | `Rich r -> to_html r 
    | `Text t -> Html.str (raw_html t)

  let length = function 
    | `Rich r -> length r
    | `Text t -> String.length t

end
