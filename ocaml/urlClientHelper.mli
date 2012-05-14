class base : string -> object 
  method path : string
  method root : MInstance.t -> string
  method key_root : string -> string
  method server : O.Action.server
end

class dflt : string -> object 
  method build : MInstance.t -> string
  method initial : MInstance.t -> string
  method path : string
  method root : MInstance.t -> string
  method key_initial : string -> string
  method key_build : string -> string
  method key_root  : string -> string
  method server : O.Action.server
end

class rest : string -> object 
  method path : string
  method rest : MInstance.t -> string list -> string
  method key_rest : string -> string list -> string
  method server : O.Action.server
end

class ajax : MInstance.t O.Box.root_action -> string list -> object 
  method build : MInstance.t -> string
  method path : string
  method rest : MInstance.t -> string list -> string
  method server : O.Box.server
end
