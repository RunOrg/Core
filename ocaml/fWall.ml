(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Reply = struct

  module Fields = struct
      
    type config = unit
    let  config = ()

    include Fmt.Make(struct      
      type json t = [ `Text ]
    end)
      
    let fields  = [ `Text ]
      
    let details = function
      | `Text -> Form.textarea ~name:"text" ~label:"wall.reply-message"
	|> Form.add_js (fun id _ -> Js.maxFieldLength MComment.max_length id)
	
    let hash = Form.prefixed_name_as_hash "wall-reply" details
      
  end
    
  module Form = Form.Make(Fields)


end

module Post = struct

  module Fields = struct
      
    type config = unit
    let  config = ()

    include Fmt.Make(struct      
      type json t = [ `Text ]
    end)
      
    let fields  = [ `Text ]
      
    let details = function
      | `Text -> Form.textarea ~name:"text" ~label:"wall.post-message"
	|> Form.add_js (fun id _ -> JsCode.seq [
	  Js.maxFieldLength 1000 id ;
	  Js.toggleParent id ".wall-post-form" "-hide" 
	]) 
	
    let hash = Form.prefixed_name_as_hash "wall-post" details
      
  end
    
  module Form = Form.Make(Fields)

end
