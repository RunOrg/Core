(* © 2013 RunOrg *)

type 'relation t

type version = <
  number   : int ; 
  filename : string ; 
  size     : float ; 
  ext      : MFile.Extension.t ;
  file     : [`GetDoc] IFile.id ; 
  time     : float ;
  author   : IAvatar.t ;
>

module Can : sig
  val view  : 'rel t -> (#O.ctx,[`View]  t option) Ohm.Run.t
  val admin : 'rel t -> (#O.ctx,[`Admin] t option) Ohm.Run.t
end

module Get : sig
  (* Core properties *)
  val id           :            'rel t -> 'rel DMS_IDocument.id
  val iid          :            'rel t -> IInstance.t  
  val repositories : [<`View|`Admin] t -> DMS_IRepository.t list 
  val name         : [<`View|`Admin] t -> string 
  val version      : [<`View|`Admin] t -> int 
  val current      : [<`View|`Admin] t -> version
  val last_update  : [<`View|`Admin] t -> (float * IAvatar.t) 
end

module Set : sig

  val name : 
       string
    -> [`Admin] t 
    -> 'any MActor.t
    -> (#O.ctx,unit) Ohm.Run.t

  val share : 
       [`Upload] DMS_IRepository.id
    -> [`Admin] t 
    -> 'any MActor.t
    -> (#O.ctx,unit) Ohm.Run.t

  val unshare : 
       [`Remove] DMS_IRepository.id
    -> [`Admin] t
    -> 'any MActor.t
    -> (#O.ctx,unit) Ohm.Run.t

end 

module All : sig

  type entry = < 
    doc     : [`Unknown] t ; 
    name    : string ; 
    version : int ; 
    update  : float * IAvatar.t ;
  >

  val in_repository :
       ?actor:'any MActor.t
    -> ?start:float
    -> count:int
    -> [<`View|`Admin] DMS_IRepository.id 
    -> (#O.ctx, entry list * float option) Ohm.Run.t

  val count_in_repository : 
       [<`View|`Admin] DMS_IRepository.id
    -> (#O.ctx, int) Ohm.Run.t

end

module Search : sig

  val by_atom : 
       actor:'any MActor.t
    -> ?start:DMS_IDocument.t
    -> count:int
    -> IAtom.t
    -> (#O.ctx, [`View] t list * DMS_IDocument.t option) Ohm.Run.t

end

val create : 
     self:'any MActor.t
  -> iid:[`Upload] IInstance.id
  -> [`Upload] DMS_IRepository.id
  -> (#O.ctx,[`PutDoc] IFile.id option) Ohm.Run.t

val add_version : 
     self:'any MActor.t 
  -> iid:[`Upload] IInstance.id 
  -> [`Admin] t 
  -> (#O.ctx,[`PutDoc] IFile.id option) Ohm.Run.t

val ready : 'any IFile.id -> (#O.ctx, DMS_IDocument.t option) Ohm.Run.t

val get : ?actor:'any MActor.t -> 'rel DMS_IDocument.id -> (#O.ctx,'rel t option) Ohm.Run.t
val view : ?actor:'any MActor.t -> 'rel DMS_IDocument.id -> (#O.ctx,[`View] t option) Ohm.Run.t
val admin : ?actor:'any MActor.t -> 'rel DMS_IDocument.id -> (#O.ctx,[`Admin] t option) Ohm.Run.t

val instance : 'any DMS_IDocument.id -> (#O.ctx,IInstance.t option) Ohm.Run.t
