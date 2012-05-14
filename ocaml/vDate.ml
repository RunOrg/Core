(* © 2012 RunOrg *)

open Ohm

let mdy_render time i18n ctx = 
  let dtime = Unix.localtime time in
  let month = I18n.get i18n (`label ("date.month."^string_of_int (1+dtime.Unix.tm_mon))) in
  let day   = View.str (string_of_int dtime.Unix.tm_mday) in
  let year  = View.str (string_of_int (1900 + dtime.Unix.tm_year)) in  
  I18n.get_param i18n "date.MDY" [month;day;year] ctx

let wmdy_render time i18n ctx = 
  let dtime = Unix.localtime time in
  let month = 
    I18n.get i18n (`label ("date.month."^string_of_int (1+dtime.Unix.tm_mon)^".long"))
  in
  let day   = View.str (string_of_int dtime.Unix.tm_mday) in
  let year  = View.str (string_of_int (1900 + dtime.Unix.tm_year)) in  
  let wday  = I18n.get i18n (`label ("date.weekday."^string_of_int (1+dtime.Unix.tm_wday))) in
  I18n.get_param i18n "date.WMDY" [wday;month;day;year] ctx

let mdyhm_render time i18n ctx = 

  let now   = Unix.gettimeofday () in
  let dnow  = Unix.localtime now and dtime = Unix.localtime time in

  let month  = I18n.get i18n (`label ("date.month."^string_of_int (1+dtime.Unix.tm_mon))) in
  let day    = View.str (string_of_int dtime.Unix.tm_mday) in
  let year   = View.str (string_of_int (1900 + dtime.Unix.tm_year)) in  
  let hour   = View.str (string_of_int dtime.Unix.tm_hour) in
  let minute = View.str (Printf.sprintf "%02d" dtime.Unix.tm_min) in
  if dnow.Unix.tm_year = dtime.Unix.tm_year then 
    I18n.get_param i18n "date.MDHM" [month;day;hour;minute] ctx
  else
    I18n.get_param i18n "date.MDYHM" [month;day;year;hour;minute] ctx

let render time i18n ctx = 
  let now = Unix.gettimeofday () in
  let default () = 
    let dnow  = Unix.gmtime now and dtime = Unix.gmtime time in
    let month = I18n.get i18n (`label ("date.month."^string_of_int (1+dtime.Unix.tm_mon))) in
    let day   = View.str (string_of_int dtime.Unix.tm_mday) in
    let year  = View.str (string_of_int (1900 + dtime.Unix.tm_year)) in  
    if dnow.Unix.tm_year = dtime.Unix.tm_year then 
      I18n.get_param i18n "date.MD" [month;day] ctx
    else
      I18n.get_param i18n "date.MDY" [month;day;year] ctx
  in
  if now > time then
    if now -. time < 60.0 then 
      I18n.get i18n (`label "date.seconds-ago") ctx
    else if now -. time < 120.0 then
      I18n.get i18n (`label "date.minute-ago") ctx
    else if now -. time < 3600.0 then 
      I18n.get_param i18n "date.minutes-ago"
	[ View.str (string_of_int (int_of_float ((now -. time) /. 60.))) ] ctx
    else if now -. time < 7200.0 then
      I18n.get i18n (`label "date.hour-ago") ctx
    else if now -. time < 86400.0 then
      I18n.get_param i18n "date.hours-ago"
	[ View.str (string_of_int (int_of_float ((now -. time) /. 3600.))) ] ctx
    else 
      default () 
    else default ()

let day_render date i18n = 
  MFmt.date_string (I18n.language i18n) date
