(* © 2013 RunOrg *)

module Signals : sig
  val on_item_img_upload : (IItem.t, unit O.run) Ohm.Sig.channel
  val on_item_doc_upload :
    (IItem.t option * string * MOldFile_extension.t * float * IOldFile.t, unit O.run) Ohm.Sig.channel
end

val prepare_pic : 
     cuid:'any ICurrentUser.id
  -> [ `PutPic ] IOldFile.id option O.run

val prepare_client_pic : 
     iid:[`Upload] IInstance.id
  -> cuid:'any ICurrentUser.id
  -> [`PutPic] IOldFile.id option O.run

val prepare_img :
     ins:[ `Upload ] IInstance.id
  -> usr:'a IUser.id
  -> item:[`Created] IItem.id
  -> [ `PutImg ] IOldFile.id option O.run

val prepare_doc :
     ins:[ `Upload ] IInstance.id
  -> usr:'a IUser.id
  -> ?item:[`Created] IItem.id
  -> unit 
  -> [ `PutDoc ] IOldFile.id option O.run

val configure :
      [<`PutPic|`PutImg|`PutDoc] IOldFile.id
  -> ?filename:string
  ->  redirect:string
  ->  ConfigS3.upload

val confirm_pic : [ `GetPic ] IOldFile.id -> unit O.run

val confirm_img : [ `GetImg ] IOldFile.id -> unit O.run

val confirm_doc : [ `GetDoc ] IOldFile.id -> unit O.run

val remove : version:MOldFile_common.version -> IOldFile.t -> bool option O.run
