(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module SendMessage = struct

  module Fields = struct
      
    type config = unit
    let  config = ()

    include Fmt.Make(struct      
      type json t = [ `Title | `Body ]
    end)
      
    let fields  = [ `Title ; `Body ]
      
    let details = function
      | `Title     -> Form.text     ~name:"title"  ~label:"messages.create-form.title"
        |> Form.add_js (fun id _ -> Js.hideLabel id)
      | `Body      -> Form.textarea ~name:"body"   ~label:"messages.create-form.body"
        |> Form.add_js (fun id _ -> Js.maxFieldLength 1000 id)
	
    let hash = Form.prefixed_name_as_hash "profile-send-message" details
      
  end
    
  module Form = Form.Make(Fields)
    
end
