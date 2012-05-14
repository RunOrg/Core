(* © 2012 RunOrg *)

open Ohm
open Ohm.Template
open Ohm.Util

let load name = MModel.Template.load "forum" name

module Home = struct
  
  let _empty = VCore.empty VIcon.Large.comments (`label "forum.list.empty")

  let _pending = 
    let _fr = load "home-pending" [
      "count", Mk.esc (fun x -> string_of_int x)
    ] `Html in 
    function `Fr -> _fr

  let _item = 
    let _fr = load "home-item" [
      "url",     Mk.esc  (#url) ;
      "name",    Mk.trad (#name) ;
      "desc",    Mk.esc  (#desc) ;
      "count",   Mk.esc  (fun x -> string_of_int (x # count));      
      "pending", Mk.sub_or (fun x -> match x # pending with None -> None | Some 0 -> None | Some x -> Some x) 
	(_pending `Fr) (Mk.empty)
    ] `Html in 
    function `Fr -> _fr	

  class item ~url ~name ~desc ~count ~pending = object

    val      url = (url : string)
    method   url = url

    val     name = (name : I18n.text)
    method  name = name

    val     desc = (desc : string)
    method  desc = desc

    val    count = (count : int)
    method count = count

    val    pending = (pending : int option)
    method pending = pending 

  end


  let home = 
    let _home = 
      let _fr = load "home" [ 
	"list",    Mk.list_or (#list) (_item `Fr) (_empty);
	"actions", Mk.box     (#actions)	    
      ] `Html in 
      function `Fr -> _fr
    in
    fun ~(list:item list) ~actions ~i18n ctx ->
      let template = _home (I18n.language i18n) in 
      to_html template (object
	method list    = list	  
	method actions i18n ctx = VActionList.list ~list:actions ~i18n ctx
      end) i18n ctx
	
end
