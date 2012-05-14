(* © 2012 RunOrg *)

class dflt : ?secure:bool -> string -> object
  method build   : string
  method initial : unit -> string
  method path    : string
  method server  : O.Box.server
end

class rest : ?secure:bool -> string -> object 
  method path   : string
  method rest   : string list -> string
  method server : O.Box.server
end

class ajax : unit O.Box.root_action -> string list -> object
  method build  : string
  method path   : string
  method rest   : unit -> string list -> string
  method server : O.Box.server
end
