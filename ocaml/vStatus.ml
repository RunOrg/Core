(* © 2012 RunOrg *)

type t = [ `Admin | `Token | `Contact ]

let admin   = `Admin
let member  = `Token
let contact = `Contact

let css_class = function
    | `Admin   -> "status-admin" 
    | `Token   -> "status-member"
    | `Contact -> "status-contact"
      
let label s = `label ("user-" ^ (css_class s))
