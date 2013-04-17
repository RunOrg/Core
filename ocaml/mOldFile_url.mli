(* © 2013 RunOrg *)

val get : 
     [<`PutImg|`GetImg|`PutPic|`GetPic|`OwnPic|`InsPic|`GetDoc|`PutDoc] IFile.id
  -> MOldFile_common.version
  -> (#Ohm.CouchDB.ctx,string option) Ohm.Run.t
