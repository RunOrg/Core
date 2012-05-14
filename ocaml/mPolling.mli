(* © 2012 RunOrg *) 

module RSS : sig

  type t = {
    link  : string ;
    title : string ;
    time  : float ;
    body  : OhmSanitizeHtml.Clean.t
  }

  module Signals : sig
    val update : (IPolling.RSS.t * t list, bool O.run) Ohm.Sig.channel
  end
    
  val poll : string -> IPolling.RSS.t O.run
  val get : IPolling.RSS.t -> t list O.run
  val disable : IPolling.RSS.t -> unit O.run
    
end
