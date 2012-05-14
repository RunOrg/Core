(* © 2012 RunOrg *)

open Ohm

module Fields = struct

  type config = unit
  let  config = ()

  include Fmt.Make(struct
    type json t = [ `Login ]
  end)

  let fields  = [ `Login ]

  let details = function
    | `Login -> Form.text ~name:"login" ~label:"login.lost-form.login"

  let hash = Form.prefixed_name_as_hash "lostpass" details

end

module Form = Form.Make(Fields)
