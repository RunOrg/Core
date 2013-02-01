(* © 2013 RunOrg *)

type t = 

  (* First request of the session. The optional string is the value
     of the 'land' GET parameter received for that first request. *)
  | First of string option 
	
  (* Each request of the session generates this entry. Parameters
     are the method (GET or POST) and the full URL (not including query string) *)
  | Request of string * string
      
  (* Identify the session as belonging to this user (regardless of how 
     it happened, but should be pushed at least once every time
     new information about user identity appears, typically when a
     session is generated. *)
  | IsUser  of IUser.t

val log : t -> (#OhmTrackLogs.ctx,unit) Ohm.Run.t
