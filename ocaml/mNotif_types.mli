(* © 2013 RunOrg *) 

type full = <
  (* From stub *)
  id      : INotif.t ; 
  mid     : IMailing.t ; 
  plugin  : INotif.Plugin.t ; 
  iid     : IInstance.t option ;
  uid     : IUser.t ;
  from    : IAvatar.t option ; 
  time    : float ; 
  read    : float option ;
  sent    : float option ; 
  solved  : float option ; 
  load    : full option O.run ; 
  nmc     : int ;
  nsc     : int ; 
  (* From render *) 
  mail    : MUser.t -> (string * string * Ohm.Html.writer) O.run ; 
  list    : Ohm.Html.writer O.run ; 
  act     : INotif.Action.t option -> string O.run ;
> ;;

type render = <
  mail : MUser.t -> (string * string * Ohm.Html.writer) O.run ; 
  list : Ohm.Html.writer O.run ;
  act  : INotif.Action.t option -> string O.run ; 
> ;;
