(* © 2013 RunOrg *)

type version = <
  number   : int ; 
  filename : string ; 
  size     : float ; 
  ext      : MFile.Extension.t ;
  file     : [`GetDoc] IFile.id option ; 
  time     : float ;
  author   : IAvatar.t ;
>

val id           : 'rel DMS_MDocument_can.t -> 'rel DMS_IDocument.id
val iid          : 'rel DMS_MDocument_can.t -> IInstance.t  
val repositories : 'rel DMS_MDocument_can.t -> DMS_IRepository.t list 
val name         : 'rel DMS_MDocument_can.t -> string 
val version      : 'rel DMS_MDocument_can.t -> int 
val current      : 'rel DMS_MDocument_can.t -> (#O.ctx,version) Ohm.Run.t
val last_update  : 'rel DMS_MDocument_can.t -> (float * IAvatar.t) 
val current_info : 'rel DMS_MDocument_can.t -> version
