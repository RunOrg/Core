(* © 2012 RunOrg *)

include MJoinFields.Simple
  
let has_stats field = 
  match field # edit with
    | `Textarea   
    | `LongText
    | `Hide       -> false
    | `Checkbox
    | `Date
    | `PickOne  _ 
    | `PickMany _ -> true
