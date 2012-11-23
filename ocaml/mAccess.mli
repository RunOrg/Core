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

val of_entity : IEntity.t -> Action.t -> t O.run
val in_group : IAvatar.t -> IGroup.t -> State.t -> bool O.run

module Signals : sig

  val of_entity : (IEntity.t * Action.t, t O.run) Ohm.Sig.channel
  val in_group  : (IAvatar.t * IGroup.t * State.t, bool O.run) Ohm.Sig.channel

end

class type ['any] context = object 
  method self             : [`IsSelf] IAvatar.id 
  method isin             : 'any IIsIn.id 
end

val test : 'any #context  -> t list -> bool O.run

val optimize : t -> t

val summarize : t -> [> `Admin | `Member ]

val delegates : t -> IAvatar.t list

val set_delegates : IAvatar.t list -> t -> t
val add_delegates : IAvatar.t list -> t -> t 
val remove_delegates : IAvatar.t list -> t -> t
