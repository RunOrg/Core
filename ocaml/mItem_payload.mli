(* © 2013 RunOrg *)

module Message : Ohm.Fmt.FMT with type t =
  < author : IAvatar.t ; text : string >

module MiniPoll : Ohm.Fmt.FMT with type t = 
  < author : IAvatar.t ; text : string ; poll : IPoll.t >

module Image : Ohm.Fmt.FMT with type t = 
  < author : IAvatar.t ; file : IOldFile.t >

module Mail : Ohm.Fmt.FMT with type t = 
  < author : IAvatar.t ; subject : string ; body : string >

module Doc : Ohm.Fmt.FMT with type t = 
  <
    author : IAvatar.t ;
    file   : IOldFile.t ;
    title  : string ;
    ext    : MOldFile.Extension.t ; 
    size   : float 
  >

include Ohm.Fmt.FMT with type t = 
  [ `Message  of Message.t 
  | `MiniPoll of MiniPoll.t
  | `Image    of Image.t
  | `Doc      of Doc.t 
  | `Mail     of Mail.t
  ]
    
