(* © 2013 RunOrg *) 

module View : sig
  val addFilter : 
       key:string 
    -> label:O.i18n
    -> query:(
          count:int
       -> ?start:Ohm.Json.t 
       -> [`IsToken] CAccess.t
       -> IAtom.t 
       -> (Ohm.Html.writer list * Ohm.Json.t option) O.run)
    -> unit
end

val register :       
     ?render:(MAtom.t -> (O.ctx,Ohm.Html.writer) Ohm.Run.t) 
  ->  search:([`IsToken] MActor.t -> IWhite.key -> IAtom.t -> (O.ctx,string) Ohm.Run.t) 
  ->  IAtom.Nature.t
  ->  unit

