(* © 2013 RunOrg *)

val extract :
     (IWhite.key,'any) Ohm.Action.request
  -> Ohm.Action.response
  -> (ICurrentUser.t option * IWhite.key * IInstance.t * MInstance.t -> Ohm.Action.response O.run) 
  -> Ohm.Action.response O.run

val extract_ajax :
     (IWhite.key,'any) Ohm.Action.request
  -> Ohm.Action.response
  -> (ICurrentUser.t option * IWhite.key * IInstance.t * MInstance.t -> Ohm.Action.response O.run) 
  -> Ohm.Action.response O.run

val action :
  (    [ `IsToken ] CAccess.t 
    -> (IWhite.key, 'a) Ohm.Action.request
    -> Ohm.Action.response
    -> Ohm.Action.response O.run)
  -> (IWhite.key, 'a) Ohm.Action.request
  -> Ohm.Action.response
  -> Ohm.Action.response O.run

val define :
     ?back:(IWhite.key -> 'a list -> string)
  ->  UrlClient.definition
  ->  ([ `IsToken ] CAccess.t -> (O.BoxCtx.t, O.Box.result) Ohm.Run.t) 
  ->  unit 

val define_admin : 
     ?back:(IWhite.key -> 'a list -> string)
  ->  UrlClient.definition
  ->  ([ `IsAdmin ] CAccess.t -> (O.BoxCtx.t, O.Box.result) Ohm.Run.t) 
  ->  unit 
