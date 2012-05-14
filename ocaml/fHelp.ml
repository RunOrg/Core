(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Page = struct

  module Edit = JoyA.Make(struct
      
    type json t = <
      title : string ;
      input : string ;
      links : string list ;
      tags  : string list ;
      show  : bool 
    > ;;

    let edit = JoyA.obj [
      JoyA.field "title" ~label:"Titre" (JoyA.string ()) ;
      JoyA.field "input" ~label:"Contenu" (JoyA.string ~editor:`area ()) ;
      JoyA.field "links" ~label:"Voir Aussi" (JoyA.array (JoyA.string ())) ;
      JoyA.field "tags"  ~label:"Tags" (JoyA.array (JoyA.string ())) ;
      JoyA.field "show"  ~label:"Visible?" JoyA.bool 
    ]
  end)
      
  module Fields = struct
    
    type config = unit       
    let  config = () 
	
    include Fmt.Make(struct
      module ITemplate = ITemplate
      type json t = [ `Page ]
    end)
    
    let fields  = [ `Page ]
      
    let details = function 
    
      | `Page      -> Form.hidden ~json:(fun _ -> true) ~name:"page" ~label:""
         |> Form.add_config_js begin fun id _ cfg ->
	   Js.Admin.joy id (Edit.edit) []
	 end
	 
    let hash = Form.prefixed_name_as_hash "help-page-edit" details
      
  end
      
  module Form = Form.Make(Fields)
    
end
