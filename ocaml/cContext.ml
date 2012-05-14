(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

type 'a simple = < 
  access_of_entity : MAccess.of_entity ;
  avatar_in_group  : MAccess.in_group ;
  accesses_message : MAccess.in_message ;
  myself           : 'a IIsIn.id ;
  cuid             : [`Unsafe] ICurrentUser.id ;
  iid              : 'a IInstance.id ;
  self_if_exists   : [`IsSelf] IAvatar.id option ;
  self             : [`IsSelf] IAvatar.id O.run
>

let make isin = 
  let r_aid  = ref (IIsIn.avatar isin) in
  let w_aid  = MAvatar.get isin |> Run.map (fun aid -> r_aid := Some aid ; aid) |> Run.memo in
  let cuid       = IIsIn.user isin in
  let iid        = IIsIn.instance isin in 
  let in_group  = MMembership.InGroup.access () in 
  let of_entity = MEntity.access () in
  let in_message = MMessage.in_message in
  ( object
    method myself           = isin
    method self             = w_aid
    method self_if_exists   = !r_aid
    method cuid             = cuid
    method iid              = iid 
    method avatar_in_group  = in_group
    method access_of_entity = of_entity
    method accesses_message = in_message
    end : 'a simple) 

let of_user uid iid = 
  let! isin = ohm (MAvatar.identify_user iid uid) in
  return (make isin)

type 'a full = < 
  access_of_entity : MAccess.of_entity ;
  avatar_in_group  : MAccess.in_group ;
  accesses_message : MAccess.in_message ;
  i18n             : Ohm.I18n.t ;
  cuid             : [`Unsafe] ICurrentUser.id ;
  iid              : 'a IInstance.id ;
  myself           : 'a IIsIn.id ;
  self_if_exists   : [`IsSelf] IAvatar.id option ;
  self             : [`IsSelf] IAvatar.id O.run ;
  instance         : MInstance.t ;
  status           : MAvatar.Status.t -> VStatus.t ;
  picture_small    : [`GetPic] IFile.id option -> string O.run ;
  white            : MWhite.Data.t option ;
  reword           : I18n.text -> I18n.text ;
> ;;

let status instance = function
  | `Contact -> VStatus.contact
  | `Token   -> VStatus.member
  | `Admin   -> 
    if instance # light && not instance # trial 
    then VStatus.member else VStatus.admin

let make_full isin instance vertical white i18n = 
  let r_aid      = ref (IIsIn.avatar isin) in
  let w_aid   = 
    MAvatar.get isin 
    |> Run.map (fun aid -> r_aid := Some aid ; aid) 
    |> Run.memo
  in
  let cuid       = IIsIn.user isin in
  let iid        = IIsIn.instance isin in 
  let in_group   = MMembership.InGroup.access () in 
  let of_entity  = MEntity.access () in
  let in_message = MMessage.in_message in
  let status     = status instance in 
  let small      = CPicture.small in 
  ( object
    method myself           = isin
    method self_if_exists   = !r_aid
    method self             = w_aid
    method cuid             = cuid
    method iid              = iid 
    method avatar_in_group  = in_group
    method access_of_entity = of_entity
    method accesses_message = in_message
    method instance         = instance
    method i18n             = i18n
    method picture_small    = small
    method status           = status
    method white            = white
    method reword           = MVertical.reword vertical 
    end : 'a full ) 

let full_of_user user iid instance i18n = 
  let! isin     = ohm (MAvatar.identify_user iid user) in
  let! vertical = ohm (MVertical.get_cached (instance # ver)) in
  let! white    = ohm (Run.opt_bind MWhite.get (instance # white)) in
  return (make_full isin instance vertical white i18n)  

let evolve_full isin ctx =
  let iid = IIsIn.instance isin in  
  ( object
    method myself           = isin
    method iid              = iid 
    method cuid             = ctx # cuid
    method self_if_exists   = ctx # self_if_exists
    method self             = ctx # self
    method status           = ctx # status
    method avatar_in_group  = ctx # avatar_in_group
    method access_of_entity = ctx # access_of_entity
    method accesses_message = ctx # accesses_message
    method instance         = ctx # instance
    method i18n             = ctx # i18n
    method picture_small    = ctx # picture_small
    method reword           = ctx # reword
    method white            = ctx # white
    end : 'a full ) 

let is_ag ctx = 
  ctx # instance # ver = IVertical.ag
