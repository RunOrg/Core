(* © 2012 RunOrg *)

open Ohm
open Ohm.Template

module Loader = MModel.Template.MakeLoader(struct let from = "tabs" end)

module Tab = Loader.Html(struct
  type t = <
    cls  : string ;
    url  : string ;
    text : I18n.text 
  > ;;
  let source  _ = "index/tabs"
  let mapping _ =  [ 
    "cls" , Mk.str  (#cls)  ;
    "url" , Mk.esc  (#url)  ;
    "text", Mk.trad (#text) ;
  ]
end)

module VTabs = Loader.Html(struct
  type t = <
    list : Tab.t list ;
    cls  : string ;
    post : string ;
    pre  : string 
  > ;;
  let source  _ = "index"
  let mapping l =  [
    "tabs",  Mk.list (#list) (Tab.template l) ;
    "class", Mk.esc  (#cls) ;
    "post",  Mk.str  (#post) ;
    "pre",   Mk.str  (#pre) ;	  
  ]
end)
 
let render ~vertical ~list ~selected ~i18n ctx = 
  if vertical then 
    let data = object 
      method list = List.map (fun (id,url,text) -> (object
	method cls  = if id = selected then "-sel" else ""
	method url  = url
	method text = text
      end)) list
      method cls  = "v-tabs"
      method pre  = "<div class='span-6'>"
      method post = "</div>"
    end in
    VTabs.render data i18n ctx     
  else
    match list with 
      | [] | [_] -> View.str "<hr/>" ctx
      | _ ->
	let data = object 
	  method list = List.map (fun (id,url,text) -> (object
	    method cls  = if id = selected then "-sel" else ""
	    method url  = url
	    method text = text
	  end)) list
	  method cls  = "tabs"
	  method pre  = ""
	  method post = ""
	end in
	VTabs.render data i18n ctx
