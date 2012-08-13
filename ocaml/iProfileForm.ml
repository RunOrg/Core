(* © 2012 RunOrg *)

open BatPervasives

include Ohm.Id.Phantom

module Assert = struct
  let view = identity 
  let edit = identity 
end

module Deduce = struct
end

module Kind = struct

  include PreConfig_ProfileFormId

end
