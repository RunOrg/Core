(* © 2013 RunOrg *) 

module View : sig
  val addFilter : 
       key:string 
    -> label:O.i18n
    -> body:([`IsToken] CAccess.t -> IAtom.t -> (O.BoxCtx.t, O.Box.result) Ohm.Run.t)
    -> unit
end

