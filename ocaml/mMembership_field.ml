(* © 2012 MRunOrg *)

include MJoinFields.Field
  
let has_stats field = 
  match field # edit with
    | `textarea   
    | `longtext
    | `hide       -> false
    | `checkbox
    | `date
    | `pickOne  _ 
    | `pickMany _ -> true
