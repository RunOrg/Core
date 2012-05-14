(* © 2012 RunOrg *)

open Ohm
open BatPervasives

let forbidden_names = 
  [ "dev"
  ; "mail"
  ; "www"
  ; "secure"
  ; "crm"
  ; "test"
  ; "admin"
  ; "local"
  ; "runorg"
  ; "store"
  ; "pay"
  ; "me" ]

let forbidden name = 
  List.mem name forbidden_names

let max_length = 32 

let rec clean name = 
  let name = 
    List.fold_left (fun name (reg,rep) ->
      Str.global_replace (Str.regexp reg) rep name) (Util.fold_accents name)
      [ "[^A-Za-z0-9]"    , "-" ;
	"-+"              , "-" ;
	"^-+"             , ""  ;
	"-+$"             , ""  ]
    |> String.lowercase
  in
  if String.length name > max_length then
    clean (String.sub name 0 max_length)
  else name	    
    
