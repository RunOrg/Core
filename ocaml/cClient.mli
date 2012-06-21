(* © 2012 RunOrg *)

val extract :
     (string,'any) Ohm.Action.request
  -> Ohm.Action.response
  -> (ICurrentUser.t option * string * IInstance.t * MInstance.t -> Ohm.Action.response O.run) 
  -> Ohm.Action.response O.run

val extract_ajax :
     (string,'any) Ohm.Action.request
  -> Ohm.Action.response
  -> (ICurrentUser.t option * string * IInstance.t * MInstance.t -> Ohm.Action.response O.run) 
  -> Ohm.Action.response O.run

val define : 
     UrlClient.definition
  -> ([ `IsToken ] CAccess.t -> (O.BoxCtx.t, O.Box.result) Ohm.Run.t) 
  -> unit 
