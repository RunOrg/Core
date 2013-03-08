(* © 2013 RunOrg *)

val create : 
     self:'any MActor.t
  -> iid:[`Upload] IInstance.id
  -> [`Upload] DMS_IRepository.id
  -> (#O.ctx,[`PutDoc] IFile.id option) Ohm.Run.t

val ready : 'any IFile.id -> (#O.ctx, DMS_IDocument.t option) Ohm.Run.t

val add_version : 
     self:'any MActor.t 
  -> iid:[`Upload] IInstance.id 
  -> [`Admin] DMS_MDocument_can.t 
  -> (#O.ctx,[`PutDoc] IFile.id option) Ohm.Run.t

