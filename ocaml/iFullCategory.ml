(* © 2012 RunOrg *)

open Ohm

include Fmt.Make(struct
  module Nature = ICategory.Nature
  type json t = ICategory.t * Nature.t option
end)
