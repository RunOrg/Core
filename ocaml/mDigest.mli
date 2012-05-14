(* © 2012 RunOrg *) 

module OfUser : sig 
  val get           : 'any IUser.id -> IDigest.t O.run
  val get_if_exists : 'any IUser.id -> IDigest.t option O.run    
  val reverse       : IDigest.t -> IUser.t list O.run
end

module Subscription : sig

  module Signals : sig
    val on_follow : (IDigest.t * IInstance.t, unit O.run) Ohm.Sig.channel
    val on_unfollow : (IDigest.t * IInstance.t, unit O.run) Ohm.Sig.channel
  end
    
  val subscribe : 'any ICurrentUser.id -> IInstance.t -> unit O.run
  val unsubscribe : 'any ICurrentUser.id -> IInstance.t -> unit O.run
    
  val follows : 'any ICurrentUser.id -> IInstance.t -> bool O.run
    
  val count_followers : IInstance.t -> int O.run

  module Backdoor : sig      
    val count : < direct : int ; member : int ; through : int ; blocked : int > O.run
  end

end

type summary = (IInstance.t * <
		  first : MBroadcast.t ;
		  next  : (IBroadcast.t * float * string) list 
                >) list


module Signals : sig
  val on_send : (IUser.t * summary, unit O.run) Ohm.Sig.channel
end

val get_summary_for_showing : IDigest.t -> summary O.run
val get_summary_for_sending : IDigest.t -> summary O.run

