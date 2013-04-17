(* © 2013 RunOrg *)

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
       [<`PutImg|`GetImg|`PutPic|`GetPic|`OwnPic|`InsPic|`GetDoc|`PutDoc] IOldFile.id
    -> version 
    -> (#Ohm.CouchDB.ctx,string option) Ohm.Run.t
end

module Upload : sig

  module Signals : sig
    val on_item_img_upload : (IItem.t, unit O.run) Ohm.Sig.channel
    val on_item_doc_upload : 
      (IItem.t option * string * Extension.t * float * IOldFile.t, unit O.run) Ohm.Sig.channel
  end

  val prepare_pic :
       cuid:'any ICurrentUser.id 
    -> [`PutPic] IOldFile.id option O.run

  val prepare_client_pic : 
       iid:[`Upload] IInstance.id
    -> cuid:'any ICurrentUser.id
    -> [`PutPic] IOldFile.id option O.run

  val prepare_img : 
       ins:[`Upload] IInstance.id
    -> usr:'any IUser.id
    -> item:[`Created] IItem.id
    -> [`PutImg] IOldFile.id option O.run

  val prepare_doc :
       ins:[`Upload] IInstance.id
    -> usr:'any IUser.id
    -> ?item:[`Created] IItem.id
    -> unit
    -> [`PutDoc] IOldFile.id option O.run

  val configure : 
        [<`PutPic|`PutImg|`PutDoc] IOldFile.id
    -> ?filename:string
    ->  redirect:string
    ->  ConfigS3.upload

  val confirm_pic : [`GetPic] IOldFile.id -> unit O.run

  val confirm_img : [`GetImg] IOldFile.id -> unit O.run

  val confirm_doc : [`GetDoc] IOldFile.id -> unit O.run

end

val set_facebook_pic : [`PutPic] IOldFile.id -> [`IsSelf] IUser.id -> OhmFacebook.details -> unit O.run

val own_pic : 'any ICurrentUser.id -> 'any IOldFile.id -> [`OwnPic] IOldFile.id option O.run

val give_pic : [`OwnPic] IOldFile.id -> [`Upload] IInstance.id -> unit O.run

val instance_pic : 'a IInstance.id -> 'b IOldFile.id -> [`InsPic] IOldFile.id option O.run

val delete_now : [`Bot] IOldFile.id -> unit O.run

val item : [<`GetImg|`GetDoc] IOldFile.id -> IItem.t option O.run

val check : 'a IOldFile.id -> version -> (#O.ctx,bool) Ohm.Run.t
