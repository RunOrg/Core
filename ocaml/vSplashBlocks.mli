(* © 2012 RunOrg *)

module Facebook : Ohm.Template.HTML with type t = unit

module Title : Ohm.Template.HTML with type t = <
  home : string ;
  products : <
    selected : bool ;
    name     : string ;
    url      : string
  > list
>

module PageHead : Ohm.Template.HTML with type t = <
  title : string ;
  text  : string
>

module Submenu : Ohm.Template.HTML with type t = <
  items : <
    selected : bool ;
    name     : string ;
    url      : string
  > list ;
  trynow : <
    name : string ;
    url  : string
  > option
>

module Composite : Ohm.Template.HTML with type t = <
  kind  : [`LLR|`LR|`LRR] ;
  left  : Ohm.I18n.html ;
  right : Ohm.I18n.html
>

module Bullet : Ohm.Template.HTML with type t = <
  title    : string ;
  subtitle : string ;
  ordered  : bool ;
  items    : string list 
>

module Pride : Ohm.Template.HTML with type t = <
  title    : string ;
  subtitle : string option ;
  text     : string ;
  link     : (string * string) option 
>

module Image : Ohm.Template.HTML with type t = <
  url  : string ;
  copyright : < 
    url  : string ;
    name : string
  > option
>

module Ribbon : Ohm.Template.HTML with type t = Ohm.I18n.html

module Important : Ohm.Template.HTML with type t = <
  title : string ;
  text  : string
>

module Video : Ohm.Template.HTML with type t = <
  height  : int ;
  poster  : string ;
  sources : <
    src  : string ;
    mime : string
  > list
> 

module Youtube : Ohm.Template.HTML with type t = string

module Price : Ohm.Template.HTML with type t = <
  title    : string ;
  subtitle : string ;
  text     : string
>

module Recommend : Ohm.Template.HTML with type t = <
  title    : string ;
  subtitle : string ;
  items : <
    quote : string ;
    who   : string ;
    org   : string
  > list 
>

module Footer : Ohm.Template.HTML with type t = <
  url  : string ;
  name : string ;
> list 

module Offer : Ohm.Template.HTML with type t = <
  title : string ;
  text  : string ;
  inc   : string list ;
  price : string 
> ;;

module Pricing : Ohm.Template.HTML with type t = <
  cols : <
    link : string ;
    name : string
  > list list ;
  rows : <
    label : string ;
    cells : <
      ticked : bool ;
      text   : string option ;
      link   : string option 
    > list
  > list ;
  foot : string
> ;;
