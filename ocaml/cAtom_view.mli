(* © 2013 RunOrg *) 

val addFilter : 
     key:string 
  -> label:O.i18n
  -> query:(
        count:int
     -> ?start:Ohm.Json.t 
     -> [`Token] CAccess.t
     -> IAtom.t 
     -> (Ohm.Html.writer list * Ohm.Json.t option) O.run)
  -> unit

