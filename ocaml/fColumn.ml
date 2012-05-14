(* © 2012 RunOrg *)

open Ohm
open Ohm.Util

module Order = struct

  let trigger = "column-order"

  module Fields = struct
      
    type config = unit
    let  config = () 

    include Fmt.Make(struct
      type json t = [ `Order | `Show of int | `Label of int ]
    end)

    let fields  = [ `Order ]

    let details = function
      | `Order   -> Form.hidden   ~json:(fun _ -> true) ~name:"order" ~label:"" 
      | `Label n -> Form.text     ~name:("label-"^string_of_int n) ~label:"column.label"
      | `Show  n -> Form.checkbox ~name:("show-"^string_of_int n) ~label:"column.show.list"

    let hash = Form.prefixed_name_as_hash "column-order" details

  end

  module Form = Form.Make(Fields)

end

