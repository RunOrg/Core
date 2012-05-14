(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* Callback manipulation *)

let callback_return x callback = callback x

type t = <
  title  : I18n.text ;
  icon   : string ;
  action : I18n.text ;
  green  : VDashboard.Green.t option ;
  desc   : I18n.text option ;
  url    : string ;
  load   : string option ;
  access : VAccessFlag.access option 
>

type 'prefix definition = 
    ( ( ('prefix * CSegs.home_pages) O.Box.box_context -> 
	('prefix * CSegs.home_pages) -> t) option -> 
      ('prefix * CSegs.home_pages) O.box) ->
    ('prefix * CSegs.home_pages) O.box

(* Rendering a dashboard element *)

let element ~icon ~url ~base ~load ~green ~access ~hasdesc = 

  let title = `label ("dashboard."^base) 
  and desc  = if hasdesc then Some (`label ("dashboard."^base^".desc")) else None
  and view  = `label ("dashboard."^base^".view")
  and green = 
    BatOption.map (fun green -> (object
      method action =  green 
      method label  = `label ("dashboard."^base^".action")
    end)) green 
  in

  ( object
    method title  = title
    method icon   = icon
    method green  = green 
    method action = view
    method desc   = desc 
    method url    = url
    method load   = load
    method access = Some (`Block access)
    end : t )
