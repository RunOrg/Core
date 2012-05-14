(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal
  
let () = CAdmin_common.register UrlAdmin.rss begin fun i18n user request response ->
  
  let title = return (View.esc "RSS Testing") in
  
  let source =
    BatOption.default "http://www.fedeb.net/index.php?format=feed&type=rss"
      (request # post "url") 
  in

  let xml = Http_client.Convenience.http_get source in

  let rss = OhmParseRss.parse xml in

  let esc str = View.write_to_string (View.esc str) in

  (* Debugging *)

  let extract_html what = 

    let lexbuf = Lexing.from_string (BatOption.default "" what) in

    let doclist = Nethtml.parse_document 
      ~dtd:Nethtml.relaxed_html40_dtd lexbuf
    in

    let whitespace = Str.regexp "^\\([ \t\r\n]\\|\194\160\\|&nbsp;\\|&emsp;\\|&ensp;\\)*$" in
    let empty string = 
      Str.string_match whitespace string 0 && Str.match_end () = String.length string
    in

    let rec tree depth doclist =
      if depth = 50 then [] else
	let tree doclist = tree (depth + 1) doclist in 
	List.concat $ List.map Nethtml.(function
	  | Data text -> if empty text then [`Text ("[[empty:"^text^"]]")] else [`Text text]
	  | Element (("p"|"center"|"h1"|"h2"|"h3"|"h4"|"h5"|"h6"|"div"
			 |"li"|"tr"|"blockquote"|"pre"),_,l) ->  [`P (tree l)] 
	  | Element (("b"|"strong"),_,l) -> [`B (tree l)] 
	  | Element (("i"|"em"),_,l) -> [`I (tree l)]
	  | Element (("br"|"hr"),_,l) -> if l = [] then [`BR] else `BR :: tree l  
	  | Element ("a",a,l) -> begin 
	    try let url = List.assoc "href" a in
		[`A (url,tree l)] 
	    with _ -> tree l
	  end  
	  | Element (("u"|"table"|"td"|"th"|"tbody"|"thead"|"tfoot"
			 |"label"|"code"|"tt"|"font"|"span"
			 |"button"|"ul"|"ol"|"small"|"strike"|"kbd"
			 |"ins"|"del"),_,l) -> tree l
	  | _ -> []) doclist
    in
    
    let tree = tree 0 doclist in 
    
    let rec print tree = List.concat (List.map (function 
      | `Text t -> [esc t]
      | `B l    -> ["<b>&lt;b&gt;</b>"] @ print l @ ["<b>&lt;/b&gt;</b>"]
      | `I l    -> ["<b>&lt;i&gt;</b>"] @ print l @ ["<b>&lt;/i&gt;</b>"]
      | `A (_,l) -> ["<b>&lt;a&gt;</b>"] @ print l @ ["<b>&lt;/a&gt;</b>"]
      | `P l    -> ["\n<b>&lt;p&gt;</b>\n"] @ print l @ ["\n<b>&lt;/p&gt;</b>\n"]
      | `BR	-> ["\n<b>&lt;br/&gt;</b>\n"])
					tree)
    in

    String.concat "" (print tree) 
  in

  let print = 
    "</div><form action='' method=GET><input name=url><button type=submit>Ok</button></form>"
      ^ String.concat "" (List.map (fun i -> 
	let desc = BatOption.default "{none}" i.OhmParseRss.Item.description in
	let parsed = OhmSanitizeHtml.parse_string desc in           
	let short = OhmSanitizeHtml.cut ~max_lines:7 ~max_chars:1000 parsed in
	"<div><ul><li>" ^ String.concat "</li><li>" [
	  "Title: " ^ BatOption.default "{none}" i.OhmParseRss.Item.title ;
	  "Author: " ^ BatOption.default "{none}" i.OhmParseRss.Item.author ;      
	  "Date: " ^ BatOption.default "{none}" i.OhmParseRss.Item.pubdate ;
	  "Description:" ^ esc (BatOption.default "{none}" i.OhmParseRss.Item.description) ; 
	  "Extracted: <pre>" ^ extract_html i.OhmParseRss.Item.description ^ "</pre>" ;
	  "Sanitized:" ^ OhmSanitizeHtml.Clean.to_json_string parsed ;
	  "Reprinted:" ^ OhmSanitizeHtml.html short ;    
	  "GUID: " ^ BatOption.default "{none}" i.OhmParseRss.Item.guid ; 
	  "Link: <a href='" ^ BatOption.default "{none}" i.OhmParseRss.Item.link ^ "'>"
	  ^ BatOption.default "{none}" i.OhmParseRss.Item.link ^ "</a>"
	] 
	^ "</li></ul>"
      ) rss)
  in

  let body = return $ View.str print in

  CCore.render ~title ~body response  

end

