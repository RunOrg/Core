(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal

let poll ctx pid = 
  match ctx # self_if_exists with 
    | Some self -> 	      
      let! answered = ohm (MPoll.Answer.answered self pid) in
      if answered then 
	CMiniPoll.show_stats ~ctx pid
      else
	CMiniPoll.show_form ~ctx pid	      
    | None -> CMiniPoll.show_stats ~ctx pid

