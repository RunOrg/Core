(* © 2013 RunOrg *)

include Ohm.Id.PHANTOM

module Assert : sig
  val put_pic   : 'any id -> [`PutPic] id
  val own_pic   : 'any id -> [`OwnPic] id
  val ins_pic   : 'any id -> [`InsPic] id
  val get_pic   : 'any id -> [`GetPic] id
  val put_img   : 'any id -> [`PutImg] id
  val get_img   : 'any id -> [`GetImg] id
  val put_doc   : 'any id -> [`PutDoc] id
  val get_doc   : 'any id -> [`GetDoc] id 
  val bot       : 'any id -> [`Bot] id
end

module Deduce : sig

  val get_pic : [<`PutPic|`OwnPic|`InsPic|`GetPic] id -> [`GetPic] id
  val get_img : [<`PutImg|`GetImg] id -> [`GetImg] id
  val get_doc : [<`PutDoc|`GetDoc] id -> [`GetDoc] id

  val make_getPic_token : 'any ICurrentUser.id -> [`GetPic] id -> string
  val from_getPic_token : 'any ICurrentUser.id -> 'a   id      -> string -> [`GetPic] id option

  val make_getImg_token : 'any ICurrentUser.id -> [`GetImg] id -> string
  val from_getImg_token : 'any ICurrentUser.id -> 'a   id      -> string -> [`GetImg] id option

  val make_getDoc_token : 'any ICurrentUser.id -> [`GetDoc] id -> string
  val from_getDoc_token : 'any ICurrentUser.id -> 'a   id      -> string -> [`GetDoc] id option

  val make_putDoc_token : 'any ICurrentUser.id -> [`PutDoc] id -> string
  val from_putDoc_token : 'any ICurrentUser.id -> 'a   id      -> string -> [`PutDoc] id option

end

