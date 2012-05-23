(* © 2012 RunOrg *)

module Data : sig
  type t = {
    invite_members : bool ;
    write_post     : bool ;
    broadcast      : bool ;
    add_picture    : bool ;
    create_event   : bool ;
    another_event  : bool ;
    invite_network : bool 
  }
end

module Step : Ohm.Fmt.FMT with type t = 
  [ `InviteMembers
  | `AGInvite 
  | `WritePost
  | `AddPicture
  | `CreateEvent
  | `CreateAG
  | `AnotherEvent
  | `InviteNetwork
  | `Broadcast ]

val get : ?force:bool -> [`IsAdmin] IInstance.id -> Data.t O.run

val next_step : Data.t -> Step.t list -> Step.t option 

val numbered_step : Step.t -> bool

val step_number : Step.t -> Step.t list -> string
