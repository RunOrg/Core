(* © 2013 RunOrg *)

val all : 
     ?start:IInboxLine.t
  -> count:int
  -> IInboxLine.Filter.t 
  -> (#O.ctx,(IInboxLine.t * MInboxLine_common.Line.t) list * IInboxLine.t option) Ohm.Run.t
