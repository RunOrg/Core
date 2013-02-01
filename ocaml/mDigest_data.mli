(* © 2013 RunOrg *)

module Item : sig
  type t = {
    what : IBroadcast.t ;
    from : IInstance.t ;
    time : float ;
    last : float ;
    size : int ;      
    via  : IBroadcast.t option 
  }
end

type delay 

type t = {
  unviewed_since  : float ;
  unsent_since    : float ;
  unsent          : int ;
  send_delay      : delay ;
  contents        : Item.t list 
}

val max_items : int

val get_if_exists : 'any IDigest.id -> t option O.run
val get : 'any IDigest.id -> t O.run

val add_items : 'any IDigest.id -> Item.t list -> unit O.run
val remove_items : 'any IDigest.id -> IBroadcast.t list -> unit O.run
val mark_seen : 'any IDigest.id -> unit O.run
val mark_sent : 'any IDigest.id -> float O.run

val delay_day : delay
val delay_week : delay 

val set_delay : 'any IDigest.id -> delay -> unit O.run

val next_sendable : unit -> IDigest.t option O.run
