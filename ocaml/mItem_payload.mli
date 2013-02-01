(* © 2013 RunOrg *)

module Message : Ohm.Fmt.FMT with type t =
  < author : IAvatar.t ; text : string >

module MiniPoll : Ohm.Fmt.FMT with type t = 
  < author : IAvatar.t ; text : string ; poll : IPoll.t >

module Image : Ohm.Fmt.FMT with type t = 
  < author : IAvatar.t ; file : IFile.t >

module Mail : Ohm.Fmt.FMT with type t = 
  < author : IAvatar.t ; subject : string ; body : string >

module Doc : Ohm.Fmt.FMT with type t = 
  <
    author : IAvatar.t ;
    file   : IFile.t ;
    title  : string ;
    ext    : MFile.Extension.t ; 
    size   : float 
  >

module Chat : Ohm.Fmt.FMT with type t = 
  < room : IChat.Room.t >

module ChatRequest : Ohm.Fmt.FMT with type t = 
  < author : IAvatar.t ; topic : string >

include Ohm.Fmt.FMT with type t = 
  [ `Message  of Message.t 
  | `MiniPoll of MiniPoll.t
  | `Image    of Image.t
  | `Doc      of Doc.t 
  | `Chat     of Chat.t 
  | `ChatReq  of ChatRequest.t 
  | `Mail     of Mail.t
  ]
    
