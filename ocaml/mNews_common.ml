(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "new" end)
module Design = struct
  module Database = MyDB
  let name = "feed"
end

module MiniJoin = Fmt.Make(struct
  module Float = Fmt.Float
  type json t = <
    a  : IAvatar.t ;    
    e  : IEntity.t ;
    s  : [ `invited   "i" of IAvatar.t
	 | `denied    "d"
	 | `added     "a" of IAvatar.t option
	 | `removed   "r" of IAvatar.t option 
	 | `requested "q" ] ; 
    t  : Float.t
  >
end)

module Login = Fmt.Make(struct
  type json t = [ `Notification "n" of IInstance.t * Json.t * IUser.t
		| `Login        "l" of IUser.t ]
end)

module Payload = Fmt.Make(struct
  type json t = 
    [ `item "i" of IItem.t
    | `join "j" of MiniJoin.t
    | `createInstance "ic" of IInstance.t
    | `networkConnect "nc" of IRelatedInstance.t
    | `login          "l"  of Login.t
    ]
end)

module MiniAccess = Fmt.Make(struct
  type json t = 
    [ `viewFeed    "vf" of IFeed.t
    | `viewEntity  "ve" of IEntity.t
    | `adminEntity "ae" of IEntity.t
    | `nobody      "n" 
    ]
end)

let access_of_miniAccess = function 
  | `viewFeed    fid -> let! feed = ohm_req_or (return [`Nobody]) $ 
			  MFeed.bot_get (IFeed.Assert.bot fid) in 
			MFeed.Get.read_access feed
  | `viewEntity  eid -> return [`Entity (eid,`View)]
  | `adminEntity eid -> return [`Entity (eid,`Manage)]
  | `nobody          -> return [`Nobody]

module Data = Fmt.Make(struct
  module Float = Fmt.Float
  let name = "News.Json.t"
  type json t = <
    t : MType.t ;
    instance   "i" : IInstance.t option ;
    avatar     "a" : IAvatar.t option ;
    entity     "e" : IEntity.t option ;
    payload    "w" : Payload.t ;
    time           : Float.t ;
    restrict   "r" : MiniAccess.t list ;
   ?backoffice "b" : bool = false
  > 
end)

module MyTable = CouchDB.Table(MyDB)(INews)(Data)

(* Actor involved in some news *)

let actor t = match t # payload with 
  | `createInstance _ 
  | `networkConnect _ 
  | `item           _ -> BatOption.map (fun aid -> `Avatar aid) (t # avatar)
  | `join           j -> begin match j # s with 
      | `invited a -> Some (`Avatar a)
      | `denied
      | `requested -> BatOption.map (fun aid -> `Avatar aid) (t # avatar)
      | `added   a
      | `removed a -> begin match a with 
	  | Some a -> Some (`Avatar a) 
	  | None   -> BatOption.map (fun aid -> `Avatar aid) (t # avatar)
      end
  end
  | `login          u -> begin match u with 
      | `Notification (_,_,u) 
      | `Login             u  -> Some (`User u)
  end 

