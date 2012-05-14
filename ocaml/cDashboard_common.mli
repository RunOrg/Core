(* © 2012 RunOrg *)

val callback_return : 'a -> ('a -> 'b) -> 'b 

type t = <
  title  : Ohm.I18n.text ;
  icon   : string ;
  action : Ohm.I18n.text ;
  green  : VDashboard.Green.t option ;
  desc   : Ohm.I18n.text option ;
  url    : string ;
  load   : string option ;
  access : VAccessFlag.access option 
>

type 'prefix definition = 
    ( ( ('prefix * CSegs.home_pages) O.Box.box_context -> 
	('prefix * CSegs.home_pages) -> t) option -> 
      ('prefix * CSegs.home_pages) O.box) ->
    ('prefix * CSegs.home_pages) O.box

val element :
     icon:string
  -> url:string
  -> base:string
  -> load:string option
  -> green:[`url of string | `js of Ohm.JsCode.t ] option
  -> access:[`Admin|`Normal|`Public]
  -> hasdesc: bool
  -> t
