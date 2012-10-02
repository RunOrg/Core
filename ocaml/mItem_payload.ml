(* © 2012 RunOrg *)

open Ohm

(* IMPORTANT : the CouchDB views assume that the payload has a field named 
   'a' containing the author's avatar-id, and will consider that the payload
   has no author if that field is missing. *)

module Message = Fmt.Make(struct
  type json t = < author "a" : IAvatar.t ; text "t" : string >
end)

module MiniPoll = Fmt.Make(struct
  type json t = < author "a" : IAvatar.t ; text "t" : string ; poll "p" : IPoll.t >
end)

module Image = Fmt.Make(struct
  type json t = < author "a" : IAvatar.t ; file "f" : IFile.t >
end)

module Mail = Fmt.Make(struct
  type json t = < author "a" : IAvatar.t ; subject "s" : string ; body "b" : string >
end)

module Doc = Fmt.Make(struct
  module Float     = Fmt.Float
  module Extension = MFile.Extension
  type json t = <
    author "a" : IAvatar.t ;
    file   "f" : IFile.t ;
    title  "t" : string ;
    ext    "e" : Extension.t ; 
    size   "s" : Float.t 
  >
end)

module Chat = Fmt.Make(struct
  open IChat
  type json t = <
    room   "r" : Room.t
  >
end)

module ChatRequest = Fmt.Make(struct
  type json t = < author "a" : IAvatar.t ; topic "t" : string >
end)

include Fmt.Make(struct
  type json t = 
    [ `Message  "m" of Message.t 
    | `MiniPoll "p" of MiniPoll.t
    | `Image    "i" of Image.t
    | `Doc      "d" of Doc.t 
    | `Chat     "c" of Chat.t 
    | `ChatReq  "r" of ChatRequest.t ]
end)
