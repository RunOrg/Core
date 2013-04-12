(* © 2013 RunOrg *)

type nospam = <
  link : bool -> string ;
  name : string ; 
  pic  : string option ;
> 

type social = <
  pic     : string option ;
  name    : string ; 
  context : string ;
  body    : MRich.OrText.t 
>

type dual = <
  html : Ohm.Html.writer ;
  text : string
>

type action = <
  pic     : string option ;
  name    : string ; 
  action  : O.i18n ; 
  detail  : dual ; 
>

type footer = <
  white : IWhite.t option ;
  name  : string option ;
  url   : string option;
  unsub : string ;
  track : string ; 
>

type payload = 
  [ `None
  | `Social of social 
  | `Action of action ]

type result = <
  subject : string ; 
  html : Ohm.Html.writer ;
  text : string ;
  from : string option ; 
>

type body = O.i18n list list

type button = <
  color : [ `Green | `Grey ] ;
  url   : string ;
  label : O.i18n
>

val grey : O.i18n -> string -> button
val green : O.i18n -> string -> button 

val render : 
     ?nospam:nospam
  -> ?from:string
  -> O.i18n
  -> payload 
  -> body 
  -> button list 
  -> footer 
  -> (#O.ctx,result) Ohm.Run.t

val boxProfile : 
     ?img:string
  -> detail:MRich.OrText.t
  -> name:string
  -> string
  -> (#O.ctx,dual) Ohm.Run.t
