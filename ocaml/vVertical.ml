(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util
open BatPervasives

let load name = MModel.Template.load "vertical" name

module Layout = struct

  let _item_no_label = 
    let _fr = load "layout-item-no_label" [
      "values", Mk.html (#values) ;
    ] `Html in
    function `Fr -> _fr

  let _item_with_label = 
    let _fr = load "layout-item-with_label" [
      "values", Mk.html (#values) ; 
      "label",  Mk.trad (fun x -> `label (x # label))
    ] `Html in 
    function `Fr -> _fr

  let _item = 
    let _fr = load "layout-section-item" [
      "with-label", Mk.sub_or 
	(fun x -> match x # label with None -> None | Some label ->
	  Some (object method label = label method values = x # values end)) 
	(_item_with_label `Fr) (Mk.empty) ;
      "without-label", Mk.sub_or
	(fun x -> match x # label with Some _ -> None | None ->
	  Some (object method values = x # values end))
	(_item_no_label `Fr) (Mk.empty)
    ] `Html in
    function `Fr -> _fr

  let _section = 
    let _fr = load "layout-section" [
      "title", Mk.trad (fun x -> `label (x # title)) ;
      "items", Mk.list (#items) (_item `Fr) 
    ] `Html in
    function `Fr -> _fr

  let _layout = 
    let _fr = load "layout" [
      "edit",        Mk.ihtml  (#edit) ;
      "description", Mk.str    (#description) ;
      "sections",    Mk.list   (#sections) (_section `Fr) ;
      "prelude",     Mk.ihtml  (#prelude) ;
    ] `Html in 
    function `Fr -> _fr

  type formatter = Json_type.t -> MEntityInfo.Format.t -> View.Context.box View.t

  let colon = `label "colon"

  let render ~formatter
      ~prelude 
      ~data 
      ~description 
      ~layout
      ~actions
      ~i18n ctx = 

    let sections = layout |> BatList.filter_map begin fun (_,section) -> 
      let items = section # items |> BatList.filter_map begin fun (_,item) -> 	
	let values = item # fields |> BatList.filter_map begin fun (_,field) ->
	  match data (field # field) with None -> None | Some value ->
	    Some (formatter value (field # format))
	end in 
	
	if values = [] then None else Some (object
	  method label  = item # label
	  method values = View.implode (View.str " · ") (fun x -> x) values
	end)
      end in
      
      if items = [] then None else Some (object
	method title = section # section
	method items = items
      end)
    end in

    let lang = I18n.language i18n in 

    let description = VText.format (match description with Some s -> s | None -> "") in

    to_html (_layout lang) (object 
      method edit        = actions
      method description = description
      method sections    = sections
      method prelude     = prelude
    end) i18n ctx

end

module Template = struct

  let formatter i18n json = 
    let empty = View.str "&nbsp;" in 
    function

      | `text -> ( match json with 
	  | Json_type.String s -> View.esc s
	  | _                  -> empty)

      | `location -> ( match json with 
	  | Json_type.String s -> 
	    (fun ctx -> ctx 
	      |> View.str "<a href=\"http://maps.google.fr/maps?f=q&amp;q=" 
	      |> View.esc (Util.urlencode s)
	      |> View.str "\" target='_blank'>"
	      |> View.esc s
	      |> View.str "</a>")
	  | _                  -> empty)

      | `link -> ( match json with 
	  | Json_type.String s -> View.str (VText.format_links s)
	  | _                  -> empty)
 	
      | `longtext -> ( match json with 
	  | Json_type.String s -> 
	    (View.str "<p>" |- View.str (VText.format s) |- View.str "</p>")
	  | _                  -> empty)
	
      | `date     -> ( match json with 
	  | Json_type.String s -> ( match MFmt.float_of_date s with
	      | Some t -> VDate.wmdy_render t i18n
	      | None   -> empty)
	  | _                  -> empty)

end

