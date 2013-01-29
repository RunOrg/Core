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

let to_text (doc:doc) = 

  let b = Buffer.create 1024 in
  let rec recprint = function 
    | `TEXT t   -> Buffer.add_string b t 
    | `BR       -> Buffer.add_char b '\n'
    | `B l    
    | `I l      -> List.iter recprint l 
    | `P l 
    | `INDENT l -> Buffer.add_char b '\n' ; List.iter recprint l ; Buffer.add_char b '\n'
    | `UL l
    | `OL l     -> List.iter (fun l -> Buffer.add_char b '\n' ; List.iter recprint l ; Buffer.add_char b '\n') l
  in

  List.iter recprint doc ;

  Buffer.contents b

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

let whitespace_chars =
  String.concat ""
    (List.map (String.make 1)
       [
         Char.chr 9;  (* HT *)
         Char.chr 10; (* LF *)
         Char.chr 11; (* VT *)
         Char.chr 12; (* FF *)
         Char.chr 13; (* CR *)
         Char.chr 32; (* space *)
       ])

let whitespace_re = Str.regexp ("[" ^ whitespace_chars ^ "]+")
let entity_re = Str.regexp "&\\([a-zA-Z0-9]+\\);"  

(* Removes consecutive whitespace, replaces entities with their unicode 
   equivalent. *)
let clean_string s = 
  let s = Str.global_replace whitespace_re " " s in
  let s = Str.global_substitute entity_re (fun s -> 
    match Str.matched_group 1 s with 
      | "iexcl"  -> "¡"
      | "cent"   -> "¢"
      | "pound"  -> "£"
      | "curren" -> "¤"
      | "yen"    -> "¥"
      | "brvbar" -> "¦"
      | "sect"   -> "§"
      | "uml"    -> "¨"
      | "copy"   -> "©"
      | "ordf"   -> "ª"
      | "laquo"  -> "«"
      | "not"    -> "¬"
      | "reg"    -> "®"
      | "macr"   -> "¯"
      | "deg"    -> "°"
      | "plusmn" -> "±"
      | "sup2"   -> "²"
      | "sup3"   -> "³"
      | "acute"  -> "´"
      | "micro"  -> "µ"
      | "para"   -> "¶"
      | "middot" -> "·"
      | "cedil"  -> "¸"
      | "sup1"   -> "¹"
      | "ordm"   -> "º"
      | "raquo"  -> "»"
      | "frac14" -> "¼"
      | "frac12" -> "½"
      | "frac34" -> "¾"
      | "iquest" -> "¿"
      | "Agrave" -> "À"
      | "Aacute" -> "Á"
      | "Acirc"  -> "Â"
      | "Atilde" -> "Ã"
      | "Auml"   -> "Ä"
      | "Aring"  -> "Å"
      | "AElig"  -> "Æ"
      | "Ccedil" -> "Ç"
      | "Egrave" -> "È"
      | "Eacute" -> "É"
      | "Ecirc"  -> "Ê"
      | "Euml"   -> "Ë"
      | "Igrave" -> "Ì"
      | "Iacute" -> "Í"
      | "Icirc"  -> "Î"
      | "Iuml"   -> "Ï"
      | "ETH"    -> "Ð"
      | "Ntilde" -> "Ñ"
      | "Ograve" -> "Ò"
      | "Oacute" -> "Ó"
      | "Ocirc"  -> "Ô"
      | "Otilde" -> "Õ"
      | "Ouml"   -> "Ö"
      | "times"  -> "×"
      | "Oslash" -> "Ø"
      | "Ugrave" -> "Ù"
      | "Uacute" -> "Ú"
      | "Ucirc"  -> "Û"
      | "Uuml"   -> "Ü"
      | "Yacute" -> "Ý"
      | "THORN"  -> "Þ"
      | "szlig"  -> "ß"
      | "agrave" -> "à"
      | "aacute" -> "á"
      | "acirc"  -> "â"
      | "atilde" -> "ã"
      | "auml"   -> "ä"
      | "aring"  -> "å"
      | "aelig"  -> "æ"
      | "ccedil" -> "ç"
      | "egrave" -> "è"
      | "eacute" -> "é"
      | "ecirc"  -> "ê"
      | "euml"   -> "ë"
      | "igrave" -> "ì"
      | "iacute" -> "í"
      | "icirc"  -> "î"
      | "iuml"   -> "ï"
      | "eth"    -> "ð"
      | "ntilde" -> "ñ"
      | "ograve" -> "ò"
      | "oacute" -> "ó"
      | "ocirc"  -> "ô"
      | "otilde" -> "õ"
      | "ouml"   -> "ö"
      | "divide" -> "÷"
      | "oslash" -> "ø"
      | "ugrave" -> "ù"
      | "uacute" -> "ú"
      | "ucirc"  -> "û"
      | "uuml"   -> "ü"
      | "yacute" -> "ý"
      | "thorn"  -> "þ"
      | "yuml"   -> "ÿ"
      | "OElig"  -> "Œ"
      | "oelig"  -> "œ"
      | "Scaron" -> "Š"
      | "scaron" -> "š"
      | "Yuml"   -> "Ÿ"
      | "fnof"   -> "ƒ"
      | "circ"   -> "ˆ"
      | "tilde"  -> "˜"
      | "Alpha"  -> "Α"
      | "Beta"   -> "Β"
      | "Gamma"  -> "Γ"
      | "Delta"  -> "Δ"
      | "Epsilon" -> "Ε"
      | "Zeta"   -> "Ζ"
      | "Eta"    -> "Η"
      | "Theta"  -> "Θ"
      | "Iota"   -> "Ι"
      | "Kappa"  -> "Κ"
      | "Lambda" -> "Λ"
      | "Mu"     -> "Μ"
      | "Nu"     -> "Ν"
      | "Xi"     -> "Ξ"
      | "Omicron" -> "Ο"
      | "Pi"     -> "Π"
      | "Rho"    -> "Ρ"
      | "Sigma"  -> "Σ"
      | "Tau"    -> "Τ"
      | "Upsilon" -> "Υ"
      | "Phi"    -> "Φ"
      | "Chi"    -> "Χ"
      | "Psi"    -> "Ψ"
      | "Omega"  -> "Ω"
      | "alpha"  -> "α"
      | "beta"   -> "β"
      | "gamma"  -> "γ"
      | "delta"  -> "δ"
      | "epsilon" -> "ε"
      | "zeta"   -> "ζ"
      | "eta"    -> "η"
      | "theta"  -> "θ"
      | "iota"   -> "ι"
      | "kappa"  -> "κ"
      | "lambda" -> "λ"
      | "mu"     -> "μ"
      | "nu"     -> "ν"
      | "xi"     -> "ξ"
      | "omicron" -> "ο"
      | "pi"     -> "π"
      | "rho"    -> "ρ"
      | "sigmaf" -> "ς"
      | "sigma"  -> "σ"
      | "tau"    -> "τ"
      | "upsilon" -> "υ"
      | "phi"    -> "φ"
      | "chi"    -> "χ"
      | "psi"    -> "ψ"
      | "omega"  -> "ω"
      | "thetasym" -> "ϑ"
      | "upsih"  -> "ϒ"
      | "piv"    -> "ϖ"
      | "nbsp"   -> "\xc2\xa0"
      | "ensp"   -> " "
      | "emsp"   -> " "
      | "thinsp" -> " "
      | "ndash"  -> "–"
      | "mdash"  -> "—"
      | "lsquo"  -> "‘"
      | "rsquo"  -> "’"
      | "sbquo"  -> "‚"
      | "ldquo"  -> "“"
      | "rdquo"  -> "”"
      | "bdquo"  -> "„"
      | "dagger" -> "†"
      | "Dagger" -> "‡"
      | "bull"   -> "•"
      | "hellip" -> "…"
      | "permil" -> "‰"
      | "prime"  -> "′"
      | "Prime"  -> "″"
      | "lsaquo" -> "‹"
      | "rsaquo" -> "›"
      | "oline"  -> "‾"
      | "frasl"  -> "⁄"
      | "euro"   -> "€"
      | "image"  -> "ℑ"
      | "weierp" -> "℘"
      | "real"   -> "ℜ"
      | "trade"  -> "™"
      | "alefsym" -> "ℵ"
      | "larr"   -> "←"
      | "uarr"   -> "↑"
      | "rarr"   -> "→"
      | "darr"   -> "↓"
      | "harr"   -> "↔"
      | "crarr"  -> "↵"
      | "lArr"   -> "⇐"
      | "uArr"   -> "⇑"
      | "rArr"   -> "⇒"
      | "dArr"   -> "⇓"
      | "hArr"   -> "⇔"
      | "forall" -> "∀"
      | "part"   -> "∂"
      | "exist"  -> "∃"
      | "empty"  -> "∅"
      | "nabla"  -> "∇"
      | "isin"   -> "∈"
      | "notin"  -> "∉"
      | "ni"     -> "∋"
      | "prod"   -> "∏"
      | "sum"    -> "∑"
      | "minus"  -> "−"
      | "lowast" -> "∗"
      | "radic"  -> "√"
      | "prop"   -> "∝"
      | "infin"  -> "∞"
      | "ang"    -> "∠"
      | "and"    -> "∧"
      | "or"     -> "∨"
      | "cap"    -> "∩"
      | "cup"    -> "∪"
      | "int"    -> "∫"
      | "there4" -> "∴"
      | "sim"    -> "∼"
      | "cong"   -> "≅"
      | "asymp"  -> "≈"
      | "ne"     -> "≠"
      | "equiv"  -> "≡"
      | "le"     -> "≤"
      | "ge"     -> "≥"
      | "sub"    -> "⊂"
      | "sup"    -> "⊃"
      | "nsub"   -> "⊄"
      | "sube"   -> "⊆"
      | "supe"   -> "⊇"
      | "oplus"  -> "⊕"
      | "otimes" -> "⊗"
      | "perp"   -> "⊥"
      | "sdot"   -> "⋅"
      | "lceil"  -> "⌈"
      | "rceil"  -> "⌉"
      | "lfloor" -> "⌊"
      | "rfloor" -> "⌋"
      | "lang"   -> "〈"
      | "rang"   -> "〉"
      | "loz"    -> "◊"
      | "spades" -> "♠"
      | "clubs"  -> "♣"
      | "hearts" -> "♥"
      | "diams"  -> "♦"
      | "lt"     -> "<"
      | "amp"    -> "&"
      | other -> "&"^other^";"
  ) s in
  s

let parse string = 

  let lexbuf = Lexing.from_string string in 

  (* STEP 1 : parse the document *)

  let doclist = Nethtml.parse_document ~dtd:Nethtml.relaxed_html40_dtd lexbuf in
  
  (* STEP 2 : extract a dirty element tree. *)

  let rec block depth doclist =
    if depth = 50 then [] else
      let depth = depth + 1 in
      List.concat $ List.map Nethtml.(function
	| Data text -> if empty text then [] else [`TEXT (clean_string text)]
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
	| Data text -> if empty text then [] else [`TEXT (clean_string text)]
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

  let to_text = function 
    | `Rich r -> to_text r
    | `Text t -> t

  let length = function 
    | `Rich r -> length r
    | `Text t -> String.length t

end
