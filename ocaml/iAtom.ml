(* © 2013 RunOrg *)

module Nature = struct
  include PreConfig_Atom.Id
  let can_create n = 
    None <> PreConfig_Atom.create_label n
  let parents n = 
    PreConfig_Atom.parents n 
end

include Ohm.Id.Phantom
