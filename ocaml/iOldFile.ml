(* © 2012 RunOrg *)

open Ohm
open BatPervasives

include Id.Phantom

module Assert = struct
  let put_pic = identity
  let own_pic = identity
  let ins_pic = identity
  let get_pic = identity
  let put_img = identity
  let get_img = identity
  let put_doc = identity
  let get_doc = identity
  let bot = identity
end

module Deduce = struct

  let get_pic = identity
  let get_img = identity
  let get_doc = identity

  let make_getPic_token user file = 
    ICurrentUser.prove "file_getPic" user [ Id.str file ]
      
  let from_getPic_token user file proof =
    if ICurrentUser.is_proof proof "file_getPic" user [ Id.str file ] 
    then Some file else None

  let make_getImg_token user file = 
    ICurrentUser.prove "file_getImg" user [ Id.str file ]
      
  let from_getImg_token user file proof =
    if ICurrentUser.is_proof proof "file_getImg" user [ Id.str file ] 
    then Some file else None

  let make_getDoc_token user file = 
    ICurrentUser.prove "file_getDoc" user [ Id.str file ]
      
  let from_getDoc_token user file proof =
    if ICurrentUser.is_proof proof "file_getDoc" user [ Id.str file ] 
    then Some file else None

  let make_putDoc_token user file = 
    ICurrentUser.prove "file_putDoc" user [ Id.str file ]
      
  let from_putDoc_token user file proof =
    if ICurrentUser.is_proof proof "file_putDoc" user [ Id.str file ] 
    then Some file else None

end
  

