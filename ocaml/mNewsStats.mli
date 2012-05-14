(* (c) 2012 RunOrg *)

module Stats : sig
  type t = <
    active_instances_30 : int ;
    active_instances_7  : int ;
    active_instances    : int ;
    active_users_30 : int ;
    active_users_7  : int ;
    active_users    : int ;
    logins_30 : int ;
    logins_7  : int ;
    logins    : int ;
    messages_30 : int ;
    messages_7  : int ;
    messages    : int
  > ;;
end

val extract : unit -> (string * Stats.t) list O.run
