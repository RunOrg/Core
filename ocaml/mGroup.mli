(* © 2013 RunOrg *)

type 'relation t 

module Vision : Ohm.Fmt.FMT with type t = [ `Public | `Normal | `Private ]

module Satellite : sig

  type action = 
    [ `Group  of [ `Manage | `Read | `Write ]
    | `Send   of [ `Inbox  | `Mail ] 
    ]

  val access : 'any t -> action -> (#O.ctx,MAvatarStream.t) Ohm.Run.t

end

module Signals : sig

  val on_delete : (IGroup.t * IAvatarSet.t, unit O.run) Ohm.Sig.channel 
    
  val on_update : (IGroup.t, unit O.run) Ohm.Sig.channel

  val on_bind_group : (   IInstance.t
                        * IGroup.t
		        * IAvatarSet.t
                        * ITemplate.Group.t 
			* [`IsSelf] IAvatar.id, unit O.run) Ohm.Sig.channel
    
end


module Can : sig

  val view  : 'any t -> (#O.ctx,[`View]  t option) Ohm.Run.t 
  val admin : 'any t -> (#O.ctx,[`Admin] t option) Ohm.Run.t 

end

module Get : sig

  (* Primary properties *)
  val id       :            'any t ->'any IGroup.id
  val vision   : [<`Admin|`View] t -> Vision.t
  val name     : [<`Admin|`View] t -> TextOrAdlib.t option 
  val group    :            'any t -> IAvatarSet.t 
  val iid      :            'any t -> IInstance.t 
  val template : [<`Admin|`View] t -> ITemplate.Group.t
  val admins   : [<`Admin|`View] t -> IAvatar.t list 

  (* Helper properties *)
  val public   : [<`Admin|`View] t -> bool 
  val status   : [<`Admin|`View] t -> [ `Website | `Secret ] option 
  val fullname : [<`Admin|`View] t -> (#O.ctx,string) Ohm.Run.t

  val is_admin :            'any t -> (#O.ctx,bool) Ohm.Run.t
  val is_all_members :      'any t -> (#O.ctx,bool) Ohm.Run.t

end

val create : 
     self:'any MActor.t
  -> name:string
  -> vision:Vision.t 
  -> iid:[`CreateGroup] IInstance.id
  -> ITemplate.Group.t
  -> (#O.ctx,IGroup.t) Ohm.Run.t 

module Set : sig
    
  val admins : 
       IAvatar.t list
    -> [`Admin] t
    -> 'any MActor.t
    -> (#O.ctx,unit) Ohm.Run.t

  val info : 
       name:TextOrAdlib.t option 
    -> vision:Vision.t
    -> [`Admin] t
    -> 'any MActor.t
    -> (#O.ctx,unit) Ohm.Run.t 

end

module All : sig

  val visible :    
       ?actor:'any MActor.t
    -> 'a IInstance.id 
    -> (#O.ctx,[`View] t list) Ohm.Run.t  

end

val get : ?actor:'any MActor.t -> 'rel IGroup.id -> (#O.ctx,'rel t option) Ohm.Run.t

val view : ?actor:'any MActor.t -> 'rel IGroup.id -> (#O.ctx,[`View] t option) Ohm.Run.t

val admin : ?actor:'any MActor.t -> 'rel IGroup.id -> (#O.ctx,[`Admin] t option) Ohm.Run.t
 
val delete : [`Admin] t -> 'any MActor.t -> (#O.ctx,unit) Ohm.Run.t 

val instance : 'any IGroup.id -> (#O.ctx,IInstance.t option) Ohm.Run.t

val admin_name : ?actor:'a MActor.t -> 'any IInstance.id -> TextOrAdlib.t O.run

module Backdoor : sig

  val refresh_atoms : [`Admin] ICurrentUser.id -> (#O.ctx,unit) Ohm.Run.t

end
