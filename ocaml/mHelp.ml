(* © 2012 MRunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "help" end)

module Data = Fmt.Make(struct
  type json t = <
    title  : string ;
    input  : string ;
    clean  : string ;
    links  : string list ;
    tags   : string list ;
    shown  : bool ;
    format : int
  >
end)

module MyTable = CouchDB.Table(MyDB)(IHelp)(Data)

(* The cleaning function. Increment format every time it changes. *)

let format = 1

let clean input =

  let raw (s,l) = String.sub input s l in
  let trim x = BatString.trim (raw x) in

  let tokens =

    let start = 0 in
    let eof n = String.length input <= n in
    let starts_with n starts =
      if n + String.length starts > String.length input then false else begin
        let ok = ref true in
        for i = 0 to String.length starts - 1 do
          if starts.[i] <> input.[i+n] then ok := false
        done ;
        !ok
      end in
    let skip n starts = (n + String.length starts) in
    let next n = n+1 in

    let read_reset n = (n,0) in
    let read_next (s,l) = (s,l+1) in
    let is_empty  (s,l) = l = 0 in

    let try_token success failure token tokstr read =
      if starts_with read tokstr then success token (skip read tokstr)
      else failure read
    in

    let rec get_token success failure list read =
      match list with
        | [] -> failure read
        | (token,tokstr) :: rest -> try_token success (get_token success failure rest) token tokstr read
    in

    let tokens =
      (None, " $$ ") ::
        List.map (fun (t,s) -> Some t, s)
        [
          `ParSkip, "\n\n" ;
          `OpenImg, "<img>" ;
          `CloseImg, "</img>" ;
          `OpenVideo, "<video>" ;
          `CloseVideo, "</video>" ;
          `OpenList, "<list>" ;
          `CloseList, "</list>" ;
          `OpenOrdered, "<olist>" ;
          `CloseOrdered, "</olist>" ;
          `OpenBold, "<b>" ;
          `CloseBold, "</b>" ;
          `OpenItalics, "<i>" ;
          `CloseItalics, "</i>" ;
          `OpenItem, "<item>" ;
          `CloseItem, "</item>" ;
          `OpenLink, "<link>" ;
          `CloseLink, "</link>" ;
	  `Section, "###:" ;
	  `SubSection, "##:" ;
        ]
    in

    let rec token str acc read =

      if eof read then if is_empty str then acc else `Text str :: acc else

        let success tok read =
          let acc = if is_empty str then acc else `Text str :: acc in
          let acc = match tok with Some tok -> tok :: acc | None -> acc in
          token (read_reset read) acc read
        in

        let failure read = token (read_next str) acc (next read) in

        get_token success failure tokens read

    in

    List.rev (token (read_reset start) [] start)

  in

  let parsed, _ =

    let parse_image = function
      | `Text name :: `Text width :: `Text height :: tokens ->
        (`Image (name, width, height)) , tokens
      | tokens -> (`Error "<image/>"), tokens
    in
    let parse_video = function
      | `Text name :: `Text width :: `Text height :: tokens ->
        (`Video (name, width, height)) , tokens
      | tokens -> (`Error "<image/>"), tokens
    in

    let rec parse_link close items = function 

      | `Text t :: tokens -> parse_link close (`Text t :: items) tokens

      | `OpenBold :: tokens ->
        let inline, tokens = parse_link `CloseBold [] tokens in
        parse_link close (`Bold inline :: items) tokens

      | `OpenItalics :: tokens ->
        let inline, tokens = parse_link `CloseItalics [] tokens in
        parse_link close (`Italics inline :: items) tokens

      | (`CloseBold | `CloseItalics | `CloseLink ) as found :: tokens ->
	if found = close then List.rev items, tokens
        else
          parse_link close (`Error (match found with
            | `CloseBold -> "</b>"
            | `CloseItalics -> "</i>"
            | `CloseLink -> "</link>"
            | _ -> "</...>"
          ) :: items) tokens

      | tokens -> List.rev items, tokens
    in

    let rec parse_inline close items = function

      | `Text t :: tokens -> parse_inline close (`Text t :: items) tokens

      | `OpenBold :: tokens ->
        let inline, tokens = parse_inline `CloseBold [] tokens in
        parse_inline close (`Bold inline :: items) tokens

      | `OpenItalics :: tokens ->
        let inline, tokens = parse_inline `CloseItalics [] tokens in
        parse_inline close (`Italics inline :: items) tokens

      | `OpenLink :: `Text t :: tokens ->
        let inline, tokens = parse_link `CloseLink [] tokens in
        parse_inline close (`Link (t, inline) :: items) tokens

      | `OpenLink :: tokens ->
        parse_inline close (`Error "<link>" :: items) tokens

      | (`CloseBold | `CloseItalics | `CloseLink ) as found :: tokens ->
        if found = close then List.rev items, tokens
        else
          parse_inline close (`Error (match found with
            | `CloseBold -> "</b>"
            | `CloseItalics -> "</i>"
            | `CloseLink -> "</link>"
            | _ -> "</...>"
          ) :: items) tokens

      | tokens -> List.rev items, tokens
    in

    let parse_paragraph tokens = parse_inline `ParSep [] tokens in

    let rec parse_block_list blocks = function
      | [] -> List.rev blocks, []

      | `Section :: `Text t :: tokens ->
	parse_block_list (`Section t :: blocks) tokens

      | `Section :: tokens ->
	parse_block_list (`Error "###:" :: blocks) tokens

      | `SubSection :: `Text t :: tokens -> 
	parse_block_list (`SubSection t :: blocks) tokens

      | `SubSection :: tokens ->
	parse_block_list (`Error "##:" :: blocks) tokens

      | (`CloseList | `CloseOrdered | `CloseItem) :: list ->
	List.rev blocks, list

      | (`ParSkip | `CloseVideo | `CloseImg | `CloseBold | `CloseItalics | `CloseLink) :: tokens ->
        parse_block_list blocks tokens

      | `OpenImg :: tokens ->
	let block, tokens = parse_image tokens in
        parse_block_list (block :: blocks) tokens

      | ((`OpenBold | `OpenLink | `OpenItalics | `Text _) :: _) as tokens ->
        let inline, tokens = parse_paragraph tokens in
        parse_block_list (`Paragraph inline :: blocks) tokens

      | `OpenVideo :: tokens ->
        let block, tokens = parse_video tokens in
        parse_block_list (block :: blocks) tokens

      | `OpenList :: tokens ->
	let list_blocks, tokens = parse_block_list [] tokens in
        parse_block_list (`List list_blocks :: blocks) tokens

      | `OpenOrdered :: tokens ->
	let list_blocks, tokens = parse_block_list [] tokens in
        parse_block_list (`Ordered list_blocks :: blocks) tokens

      | `OpenItem :: tokens ->
	let item_blocks, tokens = parse_block_list [] tokens in
        parse_block_list (`Item item_blocks :: blocks) tokens

    in

    parse_block_list [] tokens

  in

  let esc s = View.write_to_string (View.esc s) in

  let rec html_of_inline = function
    | `Error   t  -> "<span class=\"parse-error\">" ^ esc t ^ "</span>"
    | `Bold    b  -> "<b>" ^ String.concat "" (List.map html_of_inline b) ^ "</b>"
    | `Italics i  -> "<i>" ^ String.concat "" (List.map html_of_inline i) ^ "</i>"
    | `Link (u,l) -> let url = esc (trim u) in
		     let text = String.concat "" (List.map html_of_inline l) in
		     "<a href=\"" ^ url ^ "\">" ^ text ^ "</a>"
    | `Text    t  -> esc (raw t)
  in

  let rec html_of_block = function

    | `Error t -> "<span class=\"parse-error\">" ^ esc t ^ "</span>"

    | `Section t -> "<h2>" ^ esc (trim t) ^ "</h2>"
    | `SubSection t -> "<h3>" ^ esc (trim t) ^ "</h3>"

    | `Image (src, w, h) -> let src = esc (trim src) in
			    let w   = string_of_int (try int_of_string (trim w) with _ -> 0) in
			    let h   = string_of_int (try int_of_string (trim h) with _ -> 0) in
			    "<img src=\"/public/help/" ^ src ^ "\" width=\"" ^ w ^ "\" height=\"" ^ h ^ "\"/>"

    | `Video (src, w, h) -> let src = esc (trim src) in
			    let w   = string_of_int (try int_of_string (trim w) with _ -> 0) in
			    let h   = string_of_int (try int_of_string (trim h) with _ -> 0) in
			    "<object width=\"" ^ w ^ "\" height=\"" ^ h ^ "\"><param name=\"movie\" value=\"" 
			    ^ src ^ "\"></param><param name=\"allowFullScreen\" value=\"true\"></param>"
			    ^ "<param name=\"allowScriptAccess\" value=\"always\"></param><embed src=\""
			    ^ src ^ "\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\""
			    ^ " allowScriptAccess=\"always\" width=\"" ^ w ^ "\" height=\"" ^ h ^ "\"></embed></object>"

    | `Item list -> String.concat "" (List.map html_of_block list) 

    | `List [] -> ""
    | `List list -> "<ul><li>" ^ String.concat "</li><li>" (List.map html_of_block list) ^ "</li></ul>"

    | `Ordered [] -> ""
    | `Ordered list -> "<ol><li>" ^ String.concat "</li><li>" (List.map html_of_block list) ^ "</li></ol>"
    
    | `Paragraph p -> "<p>" ^ (String.concat "" (List.map html_of_inline p)) ^ "</p>"

  in
    
  String.concat "" (List.map html_of_block parsed) 

(* Creating a fresh object *)

let make ~title ~input ~links ~tags ~shown = object
  method title  = title
  method input  = input
  method clean  = clean input
  method format = format
  method links  = links
  method tags   = tags
  method shown  = shown
end

(* Database access *)

let update id ~title ~input ~links ~tags ~shown = 
  MyTable.transaction id (MyTable.insert (make ~title ~input ~links ~tags ~shown))
  |> Run.map ignore

let get id = MyTable.get id


