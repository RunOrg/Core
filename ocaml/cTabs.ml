(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives

type ('prefix, 'switch) tab = 
  | Fixed  of 'switch * Ohm.I18n.text * ('prefix * 'switch) O.box Lazy.t
  | Hidden of ('switch -> (Ohm.I18n.text * ('prefix * 'switch) O.box) option O.run)

let fixed key label box = Fixed (key,label,box)

let hidden f = Hidden f

let _default url default = Lazy.lazy_from_val begin
  O.Box.error (fun bctx (p,_) -> return (Js.redirect (url (bctx#segments) (p,default))))
end

let _process bctx url (p,selected) list = 
  Run.list_map begin function

    | Fixed (n,r,b) -> 
      return (
	(if n = selected then Some b else None) , (Some (n,url (bctx#segments) (p,n),r))
      )

    | Hidden f -> 
      f selected |> Run.map begin function
	| None -> None, None 
	| Some (r,b) -> Some (lazy b), Some (selected, url (bctx#segments) (p,selected), r)
      end

  end list

let _selected processed url default = 
  try BatList.find_map fst processed with _ -> _default url default

let _tabs processed = 
  BatList.filter_map snd processed
  
let box ~list ~default ~url ~seg ~i18n = 
  let tab = "t" in 
  O.Box.node 
    begin fun bctx (p,selected) -> 
      let process = _process bctx url (p,selected) list |> Run.memo in
      (process |> Run.map 
	  (fun processed -> [tab,Lazy.force (_selected processed url default)])),
      (process |> Run.map (fun processed -> 
	(fun ctx -> 
	  let list = _tabs processed in 
	  VTabs.render ~vertical:false ~list ~selected ~i18n ctx
	  |> O.Box.draw_container (bctx # name,tab))))
    end
  |> O.Box.parse (seg default)
    
let vertical ~list ~default ~url ~seg ~i18n = 
  let tab = "t" in 
  O.Box.node 
    begin fun bctx (p,selected) -> 
      let process = _process bctx url (p,selected) list |> Run.memo in
      (process |> Run.map
	  (fun processed -> [tab,Lazy.force (_selected processed url default)])),
      (process |> Run.map (fun processed -> 
	(fun ctx -> 
	  let list = _tabs processed in 
	  VTabs.render ~vertical:true ~list ~selected ~i18n ctx
	  |> View.str "<div class='span-12 last'>"
	  |> O.Box.draw_container (bctx # name,tab) 
	  |> View.str "</div>")))
    end
  |> O.Box.parse (seg default)


