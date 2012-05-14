(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

type details = <
  url     : string ;
  name    : string ;
  picture : string ;
  status  : VStatus.t
>

let make_details ~i18n ~ctx ~avatar ~details ~picture = ( object
  method url     = UrlProfile.page ctx avatar 
  method name    = CName.get i18n details
  method picture = picture
  method status  = ctx # status (match details # status with None -> `Contact | Some x -> x)
end : details )

let extract_one i18n ctx avatar =
  let! details = ohm $ MAvatar.details avatar in
  let! picture = ohm $ ctx # picture_small (details # picture) in
  return $ make_details ~i18n ~ctx ~avatar ~details ~picture 

let extract i18n ctx avatars = 
  Run.list_map (extract_one i18n ctx) avatars
  
let extract_map i18n ctx project sources = 
  
  let extract_source source = 
    let  avatar  = project source in
    let! details = ohm $ MAvatar.details avatar in  
    let! picture = ohm $ ctx # picture_small (details # picture) in
    return (source, make_details ~i18n ~ctx ~avatar ~details ~picture)
  in
  
  Run.list_map extract_source sources
