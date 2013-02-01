(* © 2013 RunOrg *) 

val post : MChat_line.Payload.t -> 'room IChat.Room.id -> MChat_line.t O.run

val count : 'room IChat.Room.id -> int O.run

val list : 
     ?start:IChat.Line.t
  -> ?reverse:bool
  ->  count:int
  ->  'room IChat.Room.id
  ->  (MChat_line.t list * IChat.Line.t option) O.run

