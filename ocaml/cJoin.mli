(* © 2012 RunOrg *)

module Validate : sig

  module TaskArgs : Ohm.Fmt.FMT

  val validate_many : 
       self:[`IsSelf] IAvatar.id
    -> group:[<`Admin|`Write] MGroup.t
    -> joins:IAvatar.t list
    -> TaskArgs.t Ohm.Task.token option O.run

end

module Edit : sig

  val box :
       ctx:'a CContext.full 
    -> entity:'any MEntity.t
    -> group:[<`Admin|`Write] MGroup.t 
    -> IAvatar.t 
    -> (UrlSegs.entity * 'b) O.box

end
