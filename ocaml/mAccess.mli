module Action : Ohm.Fmt.FMT with type t = 
  [ `View   (* "v" *)
  | `Manage (* "m" *)
  ]

module State : Ohm.Fmt.FMT with type t = 
  [ `Pending   (* "p" *)
  | `Validated (* "v" *)
  | `Any       (* "a" *)
  ]

type t = 
  [ `Nobody                                    (* "n" *)
  | `Admin                                     (* "o" *)
  | `Token                                     (* "m" *)
  | `TokOnly of t                              (* "t" *)
  | `Contact                                   (* "c" *)
  | `Message of IMessage.t                     (* "d" *)
  | `List    of IAvatar.t list                 (* ["l",[a,b,c,d]] *)
  | `Groups  of State.t * (IGroup.t list)      (* ["g",s,[a,b,c,d]] *)
  | `Entity  of IEntity.t * Action.t           (* ["e",a,x] *)
  | `Union   of t list                         (* ["u",[a,b,c,d]] *)
  ]

val of_json : Ohm.Json.t -> t
val to_json : t -> Ohm.Json.t
val fmt : t Ohm.Fmt.t

type of_entity  = IEntity.t -> Action.t -> t O.run
type in_group   = IAvatar.t -> IGroup.t  -> State.t  -> bool O.run
type in_message = IAvatar.t -> IMessage.t -> bool O.run

class type ['any] context = object
  method self_if_exists   : [`IsSelf] IAvatar.id option 
  method self             : [`IsSelf] IAvatar.id O.run
  method myself           : 'any IIsIn.id 
  method access_of_entity : of_entity 
  method avatar_in_group  : in_group 
  method accesses_message : in_message
end

val test : 'any #context  -> t list -> bool O.run

val optimize : t -> t

val summarize : t -> [> `Admin | `Normal | `Public ]

