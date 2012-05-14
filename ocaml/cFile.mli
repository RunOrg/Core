(* © 2012 RunOrg *)

val get_pic_fmt : [`Unsafe] ICurrentUser.id -> [`GetPic] IFile.id Ohm.Fmt.t
val get_img_fmt : [`Unsafe] ICurrentUser.id -> [`GetImg] IFile.id Ohm.Fmt.t

val get_doc_of_string :  [`Unsafe] ICurrentUser.id -> string -> [`GetDoc] IFile.id option 

val pic_uploader : 
     Ohm.I18n.t
  -> Js.id
  -> string
  -> Ohm.View.Context.box Ohm.View.t

val client_pic_uploader : 
     MInstance.t  
  -> Ohm.I18n.t
  -> Js.id
  -> string
  -> Ohm.View.Context.box Ohm.View.t
