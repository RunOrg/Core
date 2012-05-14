(* © 2012 RunOrg *)

open Ohm 

module Payload = MItem_payload 
module Float   = Fmt.Float

include Fmt.Make(struct
  type json t = <
    del            : bool ;
    delayed  "d"   : bool ;
    where    "w"   : [ `feed   "w" of IFeed.t 
		     | `album  "a" of IAlbum.t
		     | `folder "f" of IFolder.t ] ;
    payload  "p"   : Payload.t ; 
    time     "t"   : Float.t ;
    clike    "cl"  : IAvatar.t list ;
    nlike    "nl"  : int ;
    ccomm    "cc"  : IComment.t list ;
    ncomm    "nc"  : int ;
    iid            : IInstance.t 
  > 
end)

let author t = match t # payload with 
  | `Message  m -> Some (m # author) 
  | `MiniPoll p -> Some (p # author) 
  | `Image    i -> Some (i # author) 
  | `Doc      d -> Some (d # author) 
  | `Chat     c -> None
  | `ChatReq  r -> Some (r # author)
