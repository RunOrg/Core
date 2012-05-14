(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module Fields = struct

  type config = unit
  let  config = ()

  include Fmt.Make(struct
    type json t = [ `Email ]
  end)

  let fields  = [ `Email ]

  let details = function
    | `Email -> 
      Form.text ~name:"email" ~label:"index.newsletter-form.email"
      |> Form.add_js (fun id _ -> Js.hideLabel id)

  let hash = Form.prefixed_name_as_hash "newsletter" details

end

module Form = Form.Make(Fields)

