(* © 2012 RunOrg *)

open Ohm

module Content = Fmt.Make(struct
  module Clean = OhmSanitizeHtml.Clean
  type json t = 
    [ `Post "p" of < title "t": string ; body "b": string > 
    | `RSS  "r" of < title "t": string ; body "b": Clean.t ; link "l": string > ] 
end) 

type content = Content.t

type forward = <
  id     : IBroadcast.t ; 
  from   : IInstance.t ;
  author : IAvatar.t option ;
  time   : float 
> ;;

type t = <
  id       : IBroadcast.t ;
  from     : IInstance.t ;
  author   : IAvatar.t option ;
  forwards : int ;
  time     : float ;
  forward  : forward option ;
  content  : Content.t
> ;;

module Item = struct
  module T = struct
    module Float = Fmt.Float
    type json t = {
      from   "f" : IInstance.t ;
      author "a" : IAvatar.t option ;
      time   "t" : Float.t ;
      kind   "k" : 
        [ `Content "c" of < what "w" : Content.t ; forwards "f" : int >
        | `Forward "f" of < from "f" : IBroadcast.t ; real "r" : IBroadcast.t > ] ;
      delete "d" : (Float.t * IAvatar.t) option 
    }
  end
  include T
  include Fmt.Extend(T)
end

