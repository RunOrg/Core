(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Entities = CDashboard_entities
module Calendar = CDashboard_activities_calendar

let dynamic ~ctx = 

  let! events_reaction   = ohm $ Entities.block `Event  ~ctx in
  let! courses_reaction  = ohm $ Entities.block `Course ~ctx in
  let! forums_reaction   = ohm $ Entities.block `Forum  ~ctx in
  let! polls_reaction    = ohm $ Entities.block `Poll   ~ctx in
  let! albums_reaction   = ohm $ Entities.block `Album  ~ctx in
  let! calendar_reaction = ohm $ Calendar.block         ~ctx in

  return (fun callback ->  

    let! events   = events_reaction in 
    let! courses  = courses_reaction in
    let! forums   = forums_reaction in 
    let! polls    = polls_reaction in 
    let! albums   = albums_reaction in 
    let! calendar = calendar_reaction in 

    let list = [
      events ;
      courses ;
      forums ;
      polls ;
      albums 
    ] in
    
    callback (calendar, BatList.filter_map identity list)

  )
