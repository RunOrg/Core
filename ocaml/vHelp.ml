(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "help" end)

module Page = Loader.Html(struct
  type t = <
    title : string ;
    content : string 
  > ;;
  let source  _ = "page"
  let mapping _ = [
    "header",  Mk.ihtml (fun _ -> GSplash.header) ;
    "footer",  Mk.ihtml (fun _ -> GSplash.footer) ;
    "title",   Mk.esc (#title) ;
    "content", Mk.str (#content) 
  ]
end)

module Edit = Loader.Html(struct
  type t = <    
    url   : string ;
    init  : FHelp.Page.Form.t
  > ;;
  let source _ = "edit" 
  let mapping _ = [] |> FHelp.Page.Form.to_mapping
      ~prefix:"edit"
      ~url:   (#url) 
      ~init:  (#init)
end)

