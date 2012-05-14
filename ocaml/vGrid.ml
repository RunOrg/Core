(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

let estimated_width col = match col.MAvatarGrid.Column.view with 
  | `age      -> 2
  | `text     -> 4
  | `date     -> 4
  | `datetime -> 4
  | `status   -> 3
  | `checkbox -> 1
  | `pickAny  -> 4

let render ~width ~url ~cols ~edit ~i18n ctx = 
  let fullwidth = 
    max (List.fold_left (fun a c -> a + estimated_width c) 0 cols) 1
  in

  let width = width - 11 * (List.length cols) in

  let cols = 
    BatList.mapi (fun i c -> 
      Js.Grid.column 
	~index:(i+1) 	
	~sort:true
	~width:(width * estimated_width c / fullwidth)
	~label:(I18n.translate i18n (c.MAvatarGrid.Column.label))
	()
    ) cols 
  in

  let id = Id.gen () in
  ctx
  |> View.str "<div id=\""
  |> View.esc (Id.str id)
  |> View.str "\"><div class=\"big-loading\"/></div>"
  |> View.Context.add_js_code (Js.Grid.grid ~id ~url ~cols ~edit)
