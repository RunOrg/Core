(* © 2012 MRunOrg *)

val get : 
     [<`PutImg|`GetImg|`PutPic|`GetPic|`OwnPic|`InsPic|`GetDoc|`PutDoc] IFile.id
  -> MFile_common.version
  -> string option O.run
