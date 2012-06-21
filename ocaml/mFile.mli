(* © 2012 RunOrg *)

module Usage : sig
  val instance : [`SeeUsage] IInstance.id -> (float * float) O.run    
  val user : [`IsSelf] IUser.id -> (float * float) O.run
end

type version = [ `Original | `File | `Large | `Small ]

module Extension : Ohm.Fmt.FMT with type t = 
  [ `File
  | `Text
  | `Image
  | `Powerpoint
  | `Excel
  | `Word
  | `Web
  | `Archive
  | `PDF 
  ]

module Url : sig
  val get : 
       [<`PutImg|`GetImg|`PutPic|`GetPic|`OwnPic|`InsPic|`GetDoc|`PutDoc] IFile.id
    -> version 
    -> (#Ohm.CouchDB.ctx,string option) Ohm.Run.t
end

module Upload : sig

  module Signals : sig
    val on_item_img_upload : (IItem.t, unit O.run) Ohm.Sig.channel
    val on_item_doc_upload : 
      (IItem.t * string * Extension.t * float * IFile.t, unit O.run) Ohm.Sig.channel
  end

  val prepare_pic :
       cuid:'any ICurrentUser.id 
    -> [`PutPic] IFile.id option O.run

  val prepare_client_pic : 
       ins:[`Upload] IInstance.id
    -> usr:'any IUser.id
    -> [`PutPic] IFile.id option O.run

  val prepare_img : 
       ins:[`Upload] IInstance.id
    -> usr:'any IUser.id
    -> item:[`Created] IItem.id
    -> [`PutImg] IFile.id option O.run

  val prepare_doc :
       ins:[`Upload] IInstance.id
    -> usr:'any IUser.id
    -> item:[`Created] IItem.id
    -> [`PutDoc] IFile.id option O.run

  val configure : 
        [<`PutPic|`PutImg|`PutDoc] IFile.id
    -> ?filename:string
    ->  redirect:string
    ->  ConfigS3.upload

  val confirm_pic : [`GetPic] IFile.id -> unit O.run

  val confirm_img : [`GetImg] IFile.id -> unit O.run

  val confirm_doc : [`GetDoc] IFile.id -> unit O.run

end

val set_facebook_pic : [`PutPic] IFile.id -> [`IsSelf] IUser.id -> OhmFacebook.details -> unit O.run

val own_pic : 'any ICurrentUser.id -> 'any IFile.id -> [`OwnPic] IFile.id option O.run

val give_pic : [`OwnPic] IFile.id -> [`Upload] IInstance.id -> unit O.run

val instance_pic : IInstance.t -> 'any IFile.id -> [`InsPic] IFile.id option O.run

val delete_now : [`Bot] IFile.id -> unit O.run

val item : [<`GetImg|`GetDoc] IFile.id -> IItem.t option O.run
