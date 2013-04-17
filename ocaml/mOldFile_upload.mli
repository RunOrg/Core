(* © 2013 RunOrg *)

module Signals : sig
  val on_item_img_upload : (IItem.t, unit O.run) Ohm.Sig.channel
  val on_item_doc_upload :
    (IItem.t option * string * MOldFile_extension.t * float * IFile.t, unit O.run) Ohm.Sig.channel
end

val prepare_pic : 
     cuid:'any ICurrentUser.id
  -> [ `PutPic ] IFile.id option O.run

val prepare_client_pic : 
     iid:[`Upload] IInstance.id
  -> cuid:'any ICurrentUser.id
  -> [`PutPic] IFile.id option O.run

val prepare_img :
     ins:[ `Upload ] IInstance.id
  -> usr:'a IUser.id
  -> item:[`Created] IItem.id
  -> [ `PutImg ] IFile.id option O.run

val prepare_doc :
     ins:[ `Upload ] IInstance.id
  -> usr:'a IUser.id
  -> ?item:[`Created] IItem.id
  -> unit 
  -> [ `PutDoc ] IFile.id option O.run

val configure :
      [<`PutPic|`PutImg|`PutDoc] IFile.id
  -> ?filename:string
  ->  redirect:string
  ->  ConfigS3.upload

val confirm_pic : [ `GetPic ] IFile.id -> unit O.run

val confirm_img : [ `GetImg ] IFile.id -> unit O.run

val confirm_doc : [ `GetDoc ] IFile.id -> unit O.run

val remove : version:MOldFile_common.version -> IFile.t -> bool option O.run
