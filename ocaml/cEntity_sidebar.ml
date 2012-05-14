(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

(* Sidebar rendering *)

let render_sidebar ctx input prefix current available = 
  let url seg = UrlR.build (ctx # instance) (input # segments) (prefix,seg) in
  let icon = function
    | `People
    | `Wall 
    | `Chat
    | `Info
    | `Album
    | `Folder
    | `Votes           -> VIcon.shading
    | `Admin_Edit      -> VIcon.pencil
    | `Admin_People    -> VIcon.table
    | `Admin_Rights    -> VIcon.key
    | `Admin_Payment   -> VIcon.coins
    | `Admin_Propagate -> VIcon.link
    | `Admin_Fields    -> VIcon.application_form
    | `Admin_Columns   -> VIcon.table_gear
    | `Admin_Stats     -> VIcon.chart_bar
  in
  let label = function
    | `People          -> `label "entity.tab.group.participants"
    | `Wall            -> `label "entity.tab.wall"
    | `Chat            -> `label "entity.tab.chat"
    | `Info            -> `label "entity.tab.info"
    | `Album           -> `label "entity.tab.album"
    | `Folder          -> `label "entity.tab.folder"
    | `Votes           -> `label "entity.tab.votes"
    | `Admin_Edit      -> `label "entity.tab.edit"
    | `Admin_People    -> `label "entity.tab.group.participants"
    | `Admin_Stats     -> `label "entity.tab.stats"
    | `Admin_Payment   -> `label "entity.tab.payment"
    | `Admin_Rights    -> `label "entity.option.tab.access"
    | `Admin_Fields    -> `label "entity.option.tab.fields"
    | `Admin_Columns   -> `label "entity.option.tab.cols"
    | `Admin_Propagate -> `label "entity.option.tab.link"
  in

  let is_admin = function
    | `Admin_Edit -> true
    | _           -> false
  in 

  let sections = [
    `Info ;
    `Votes ; 
    `Wall ;
    `Chat ;
    `People ;
    `Album ;
    `Folder ; 
    `Admin_Edit
  ] in
  let subsections = function
    | `Admin_Edit -> [ `Admin_Edit ;
		       `Admin_People ;
		       `Admin_Fields ; 
		       `Admin_Stats ;
		       `Admin_Payment ;
		       `Admin_Rights ;
		       `Admin_Columns ;
		       `Admin_Propagate ]
    | _ -> []
  in

    let subsection key =
    if List.mem_assoc key available then
      Some (object
	method selected = current = key
	method url      = url   key
	method label    = label key
	method icon     = icon  key 
      end) 
    else None
  in

  let section key = 
    let subsections = subsections key in 
    if List.mem_assoc key available
    && ( List.exists (fun sub -> List.mem_assoc sub available) subsections 
	 || subsections = [] )
    then
      let selected = List.mem current (key :: subsections) in
      Some (object
	method selected = selected
	method opened   = selected
	method admin    = is_admin key  
	method url      = url key
	method label    = if is_admin key then `label "menu.admin" else label key  
	method contents = BatList.filter_map subsection subsections
      end)
    else None
  in

  BatList.filter_map section sections

(* Rendering the actual tabs in the sidebar *)

type info = <
  picture   : string option ;
  name      : I18n.text ;
  url_asso  : string ;
  name_asso : string ;
  url_list  : string ;
  kind      : MEntityKind.t ;
  desc      : I18n.text ;
  join      : I18n.t -> View.html ;
  invited   : bool ;
  eid       : IEntity.t
> ;;

let tabs ctx info forbidden default available =
  let content = "c" in
  O.Box.node begin fun input (prefix,url) ->
    let sub_boxes = 
      let box = try List.assoc url available with Not_found -> forbidden in 
      return [ content, box ]      
    and body = 
      
      let sidebar = render_sidebar ctx input prefix url available in

      let info = info input in

      let data = object
	method box        = (input#name, content)
	method sidebar    = sidebar
	method home       = UrlR.build (ctx # instance) (input # segments) (prefix,default)
	method picture    = info # picture
	method name       = info # name
	method url_asso   = info # url_asso
	method name_asso  = info # name_asso 
	method url_list   = info # url_list
	method kind       = info # kind
	method desc       = info # desc 
	method join       = info # join  
	method invited    = info # invited
	method eid        = info # eid
      end in

      return (VEntity.Sidebar.render data (ctx # i18n)) 
    in

    sub_boxes, body
  end
  |> O.Box.parse CSegs.entity_tabs
