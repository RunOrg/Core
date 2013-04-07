(* © 2013 RunOrg *) 

type t = 
    [ `UpgradeToAdmin  of IUser.t * IInstance.t * IAvatar.t
    | `UpgradeToMember of IUser.t * IInstance.t * IAvatar.t
    ]

val upgrade_to_admin : uid:IUser.t -> iid:IInstance.t -> from:IAvatar.t -> (#O.ctx,unit) Ohm.Run.t
val upgrade_to_member : uid:IUser.t -> iid:IInstance.t -> from:IAvatar.t -> (#O.ctx,unit) Ohm.Run.t

val define : (t MNotif.Types.stub -> MNotif.Types.render option O.run) -> unit  
