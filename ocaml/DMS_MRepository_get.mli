(* © 2013 RunOrg *)

(* Primary properties *)
val id        :            'any DMS_MRepository_can.t ->'any DMS_IRepository.id
val vision    : [<`Admin|`View] DMS_MRepository_can.t -> DMS_MRepository_vision.t
val name      : [<`Admin|`View] DMS_MRepository_can.t -> string
val iid       :            'any DMS_MRepository_can.t -> IInstance.t 
val admins    : [<`Admin|`View] DMS_MRepository_can.t -> IAvatar.t list 
val upload    : [<`Admin|`View] DMS_MRepository_can.t -> DMS_MRepository_upload.t 
(* Helper properties *)
val uploaders : [<`Admin|`View] DMS_MRepository_can.t -> IAvatar.t list   

