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

let from_generic iid gid = function
  | `profile what -> begin match what with 
      | `fullname  -> `Avatar  (iid,`Name)
      | `firstname -> `Profile (iid,`Firstname)
      | `lastname  -> `Profile (iid,`Lastname)
      | `email     -> `Profile (iid,`Email)
      | `birthdate -> `Profile (iid,`Birthdate)
      | `city      -> `Profile (iid,`City)
      | `address   -> `Profile (iid,`Address)
      | `zipcode   -> `Profile (iid,`Zipcode)
      | `country   -> `Profile (iid,`Country)
      | `phone     -> `Profile (iid,`Phone)
      | `cellphone -> `Profile (iid,`Cellphone)
      | `gender    -> `Profile (iid,`Gender)
  end 
  | `join (_,what) -> `Group (gid, begin match what with 
      | `state   -> `Status
      | `date    -> `Date
      | `inList  -> `InList
      | `field n -> `Field n
  end)
