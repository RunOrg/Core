(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include Fmt.Make(struct
  type json t = 
    [ `NewWallItem  "i"  of [`WallReader "r"|`WallAdmin "a"] * IItem.t
    | `NewFavorite  "f"  of [`ItemAuthor "a"] * IAvatar.t * IItem.t
    | `NewComment   "c"  of [`ItemAuthor "a"|`ItemFollower "f"] * IComment.t
    | `BecomeMember "bm" of IInstance.t * IAvatar.t 
    | `BecomeAdmin  "ba" of IInstance.t * IAvatar.t  
    | `NewInstance  "ni" of IInstance.t * IAvatar.t 
    | `NewUser      "nu" of IUser.t 
    | `NewJoin      "nj" of IInstance.t * IAvatar.t  
    ]
end)

let access cuid iid = 
  let! isin = ohm $ MAvatar.identify iid cuid in
  let! isin = req_or (return None) $ IIsIn.Deduce.is_token isin in
  let! self = ohm $ MAvatar.get isin in 
  return $ Some (object
    method self = self
    method isin = isin
   end)

let instance = function 
    | `NewWallItem (_,itid)
    | `NewFavorite (_,_,itid) -> MItem.iid itid
    | `NewComment (_,cid) -> let! itid    = ohm_req_or (return None) $ MComment.item cid in 
			     MItem.iid itid

    | `BecomeMember (iid,_) 
    | `BecomeAdmin (iid,_) 
    | `NewInstance (iid,_)
    | `NewJoin (iid,_) -> return $ Some iid 

    | `NewUser _ -> return None
	
let author cuid = 
  (* Act as a confirmed user for the purposes of extracting author information *)
  let cuid = ICurrentUser.Assert.is_old cuid in 
  function 

    | `NewWallItem (_,itid) -> 
      let! iid     = ohm_req_or (return None) $ MItem.iid itid in
      let! access  = ohm_req_or (return None) $ access cuid iid in
      let! item    = ohm_req_or (return None) $ MItem.try_get access itid in
      let! author  = req_or (return None) $ MItem.author_by_payload (item # payload) in
      return $ Some (`Person (author, item # iid))
	
    | `NewFavorite (_,aid,_) -> 
      let! details = ohm $ MAvatar.details aid in
      let! iid     = req_or (return None) (details # ins) in
      return $ Some (`Person (aid, iid)) 
	
    | `NewComment (_,cid) ->
      let! itid    = ohm_req_or (return None) $ MComment.item cid in 
      let! iid     = ohm_req_or (return None) $ MItem.iid itid in
      let! access  = ohm_req_or (return None) $ access cuid iid in
      let! item    = ohm_req_or (return None) $ MItem.try_get access itid in 
      let! _, comm = ohm_req_or (return None) $ MComment.try_get (item # id) cid in 
      return $ Some (`Person (comm # who, item # iid))
	
    | `BecomeMember (iid,aid) -> 
      return $ Some (`Person (aid,iid))
	
    | `BecomeAdmin (iid,aid) -> 
      return $ Some (`Person (aid,iid))
	
    | `NewInstance (iid,aid) -> 
      return $ Some (`Person (aid,iid))
	
    | `NewUser _ -> 
      return $ Some (`RunOrg None)
	
    | `NewJoin (iid,aid) -> 
      return $ Some (`Person (aid,iid))
	
let channel : t -> MNotifyChannel.t = function 
  | `NewWallItem  (what,_)   -> `NewWallItem what
  | `NewFavorite  (what,_,_) -> `NewFavorite what
  | `NewComment   (what,_)   -> `NewComment what
  | `BecomeMember (_,_)      -> `BecomeMember
  | `BecomeAdmin  (_,_)      -> `BecomeAdmin
  | `NewInstance  (_,_) 
  | `NewUser       _
  | `NewJoin      (_,_)      -> `SuperAdmin
