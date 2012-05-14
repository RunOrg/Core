(* © 2012 RunOrg *)

open Ohm

let link_regexp =  
  Str.regexp 
    ( "https?://[-a-zA-Z0-9.+=%_?&;#/]+[-a-zA-Z0-9=_?&;/#]\\|" 
      ^ "www\\.[-a-zA-Z0-9.+=%_?&;#/]+[-a-zA-Z0-9=_?&;/#]\\|" 
      ^ "[a-zA-Z0-9+-_.]+@[a-zA-Z0-9+-_.]+" )

let secure_link link = 
  if BatString.starts_with link "http://" then link else
    if BatString.starts_with link "https://" then link else
      "http://" ^ link

let link_replace string  = 
  Str.global_substitute link_regexp begin fun str ->
    let repl = Str.matched_string str in 
    let subs = Printf.sprintf "<a rel='nofollow' target='_blank' href=\"%s%s\">%s</a>" 
      (try let _ = String.index repl '@' in "mailto:" with Not_found -> 
	if BatString.starts_with repl "http" then "" else "http://")
      repl 
      (if BatString.starts_with repl "http://" then BatString.tail repl 7 else
	  if BatString.starts_with repl "https://" then BatString.tail repl 8 else repl) 
    in subs
  end string 

let format_links text = 
  let with_esc   = View.write_to_string (View.esc text) in
  let with_links = link_replace with_esc in
  with_links

let format ?(icons=[]) text = 
  let with_esc   = View.write_to_string (View.esc text) in
  let with_links = link_replace with_esc in
  let with_trim = 
    let regex = Str.regexp "[\t ]*\n[\t ]*" in
    Str.global_replace regex "\n" with_links
  in
  let with_paragraphs = 
    let regex = Str.regexp "\n\n+" in
    Str.global_replace regex "</p><p>" with_trim
  in
  let with_newlines = 
    let regex = Str.regexp "\n" in
    Str.global_replace regex "<br/>" with_paragraphs
  in
  let apply_icon string (key,icon) = 
    let regex = Str.regexp key in 
    Str.global_replace regex ("<img src=\"" ^ icon ^ "\"/>") string
  in  
  List.fold_left apply_icon with_newlines icons

let format_mail text =
  let with_trim = 
    let regex = Str.regexp "[\t ]*\n[\t ]*" in
    Str.global_replace regex "\n" text
  in
  let regex = Str.regexp "\n\n+" in
  Str.global_replace regex "\n\n" with_trim
    
let head count text =
  let regex = Str.regexp "[^\n\t ]+" in
  let rec search acc i = 
    try 
      ignore (Str.search_forward regex text i) ;
      let matched = Str.matched_string text in
      if acc = "" then 
	search matched (Str.match_end ())
      else if String.length acc + String.length matched > count then 
	acc ^ " ..."
      else 
	search (acc ^ " " ^ matched) (Str.match_end ())
    with Not_found ->
      acc
  in
  search "" 0
