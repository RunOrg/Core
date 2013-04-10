(* © 2013 RunOrg *) 

open Ohm 
open Ohm.Universal

type render_mail = 
  [`IsSelf] IUser.id -> MUser.t -> VMailBrick.result O.run 
    
type act = 
    ICurrentUser.t -> IWhite.t option -> IMail.Action.t option -> string O.run 
    
type render_item = 
    MUser.t -> (IMail.Action.t option -> string) -> Ohm.Html.writer O.run 
      
type info = <
  id      : IMail.t ; 
  wid     : IMail.Wave.t ; 
  plugin  : IMail.Plugin.t ; 
  iid     : IInstance.t option ;
  uid     : IUser.t ;
  from    : IAvatar.t option ; 
  time    : Date.t ;     
  opened  : Date.t option ; 
  clicked : Date.t option ; 
  sent    : Date.t option ; 
  zapped  : Date.t option ; 
  blocked : bool ; 
  solved  : [ `Solved of Date.t | `NotSolved of IMail.Solve.t ] option ; 
  accept  : bool option ;
> ;;

type mail = <
  info    : info ;
  mail    : render_mail ;
  act     : act ; 
> ;;

type item = <
  info    : info ;
  item    : render_item ;
  act     : act ;
> ;;

type render = <
  act  : act ;
  mail : render_mail ;
  item : render_item option ;
> ;;
