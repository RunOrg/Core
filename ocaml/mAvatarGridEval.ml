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
	]
    | `Group   of IGroup.t * 
	[ `Status 
	| `Date
	| `InList
	| `Field of string
	]
    ]
end)
