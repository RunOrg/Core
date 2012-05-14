(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Create = struct

  module Fields = struct
      
    type config = unit 
    let  config = ()

    include Fmt.Make(struct
      type json t = [ `Text | `Multiple | `Answer of int ]
    end)

    let fields  = [ `Text ; `Multiple ; `Answer 0 ; `Answer 1 ; `Answer 2 ; `Answer 3 ; `Answer 4 ; `Answer 5 ]

    let details = function 

      | `Text      -> Form.textarea ~name:"text" ~label:"wall.poll.field.question"
	|> Form.add_js (fun id _ -> JsCode.seq [
	  Js.maxFieldLength 200 id ;
	  Js.hideLabel id 	  
	])

      | `Multiple  -> Form.checkbox ~name:"multiple"  ~label:"wall.poll.field.multiple"
	
      | `Answer i  -> Form.text     ~name:("answer_" ^ string_of_int i) ~label:("wall.poll.field.answer."^string_of_int (i+1))
	|> Form.add_js (fun id _ -> Js.hideLabel id)

    let hash = Form.prefixed_name_as_hash "poll-create" details

  end

  module Form = Form.Make(Fields)

end

module Single = struct

  module Fields = struct

    type config = <
      answers : (int * I18n.text) list
    > ;;

    let  config = object
      method answers = []
    end
    
    include Fmt.Make(struct
      type json t = [ `Question ]
    end)

    let fields  = [ `Question ] 

    let details = function
      | `Question -> Form.radio ~name:"question" ~label:"" ~values:(fun config -> config # answers) 
	~renderer:(fun (idx,text) -> Json_type.Build.int idx , text)

    let hash = Form.prefixed_name_as_hash "poll-single" details	

  end

  module Form = Form.Make(Fields)

end

module Multiple = struct

  module Fields = struct

    type config = <
      answers : (int * I18n.text) list
    > ;;

    let  config = object
      method answers = []
    end

    include Fmt.Make(struct
      type json t = [ `Answer of int ]
    end)

    let fields  = [] 

    let details = function
      | `Answer n -> Form.Dyn.checkbox 
	~name:("answer-"^string_of_int n) 
	~label:(fun config -> try List.assoc n (config # answers) with Not_found -> `label "")
	  
    let hash = Form.prefixed_name_as_hash "poll-multiple" details	

  end

  module Form = Form.Make(Fields)
        

end
