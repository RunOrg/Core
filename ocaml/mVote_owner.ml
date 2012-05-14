(* © 2012 RunOrg *)

include Ohm.Fmt.Make(struct
  type json t = 
    [ `entity "e" of IEntity.t ] 
end)
