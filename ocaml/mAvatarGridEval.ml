(* © 2012 RunOrg *)

open Ohm

include Ohm.Fmt.Make(struct
  type json t = 
    [ `Avatar  of IInstance.t * [ `Name ] 
    | `Profile of IInstance.t * 
	[ `Firstname 
	| `Lastname
	| `Email
	| `Birthdate
	| `City
	| `Address
	| `Zipcode
	| `Country
	| `Phone
	| `Cellphone
	| `Gender 
	| `Full 
	]
    | `Group   of IGroup.t * 
	[ `Status 
	| `Date
	| `InList
	| `Field of string
	]
    ]
end)
 
module FullProfile = Fmt.Make(struct
  type json t = <
    fullname "n" : string option ;
    gender   "g" : [`m|`f] option ;
    picture  "p" : string option ;
    email    "e" : string option ;
  >
end)
