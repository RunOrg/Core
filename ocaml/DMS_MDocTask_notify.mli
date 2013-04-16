(* © 2013 RunOrg *)

type t = <
  what : [ `NewState    of Ohm.Json.t 
	 | `SetAssigned of IAvatar.t (* Who is the new assignee ? *)
	 | `SetNotified ] ;
  uid  : IUser.t ;
  iid  : IInstance.t ;
  dtid : DMS_IDocTask.t ;
  did  : DMS_IDocument.t ; 
  from : IAvatar.t ;
>

val define : 
  ([`IsSelf] IUser.id -> MUser.t -> t -> MMail.Types.info -> MMail.Types.render option O.run) -> unit
