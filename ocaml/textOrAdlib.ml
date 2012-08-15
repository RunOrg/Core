(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module TheAdLib = Fmt.Make(struct
  type json t = (PreConfig_Adlibs.t)
  let t_of_json json = 
    try t_of_json json with exn -> 
      match json with 
	| Json.String s -> begin 
	  match PreConfig_Adlibs.recover s with 
	    | None -> raise exn
	    | Some t -> t
	end
	| _ -> raise exn
end)

include Fmt.Make(struct
  type json t = [ `label "l" of TheAdLib.t | `text "t" of string ]

  module Old = Fmt.Make(struct
    type json t = [ `label of TheAdLib.t | `text of string ] 
  end)

  let t_of_json json = 
    try t_of_json json with exn -> 
      try Old.of_json json with _ -> raise exn

end)

let to_string = function
  | `text  t -> return t
  | `label l -> AdLib.get (`PreConfig l)

let to_html = function
  | `text  t -> return (Html.esc t) 
  | `label l -> AdLib.write (`PreConfig l)
