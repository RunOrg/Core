(* © 2013 RunOrg *)

val delete : MFile_handle.t -> (#O.ctx,unit) Ohm.Run.t
val uploader : MFile_handle.t -> (#O.ctx,[`Avatar of IAvatar.t | `User of IUser.t] option) Ohm.Run.t

val upload : 
     MFile_store.t 
  -> [`Avatar of IAvatar.t | `User of IUser.t]
  -> public:bool 
  -> filename:string 
  -> string 
  -> (#O.ctx, MFile_handle.t option) Ohm.Run.t

val register : 
     MFile_handle.t
  -> [`Avatar of IAvatar.t | `User of IUser.t] option
  -> size:float
  -> filename:string
  -> (#O.ctx,unit) Ohm.Run.t

