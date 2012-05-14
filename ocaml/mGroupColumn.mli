(* © 2012 MRunOrg *)

module View : Ohm.JoyA.FMT with type t = 
  [ `text
  | `date
  | `datetime
  | `status
  | `checkbox
  | `age 
  | `pickAny
  ]

module Eval : Ohm.Fmt.FMT with type t = 
  [ `profile of [ `firstname 
		| `lastname 
		| `email 
		| `birthdate
		| `phone
		| `cellphone 
		| `address
		| `zipcode
		| `city
		| `country
		| `gender 
		] 
  | `join    of int * [ `state 
		      | `date 
		      | `field of string ]
  ]

(* {{{{* )        
module Column : Ohm.Fmt.FMT with type t = 
  <
    sort : bool ;
    label : [`label of string | `text of string];
    eval : Eval.t ;
    view : View.t ;
    pos  : int ;
    show : bool 
  >

module Columns : Ohm.Fmt.FMT with type t = Column.t list
    
type sorted  = (int * Column.t) list

module SetColumn : Ohm.Fmt.FMT with type t = 
  <
    sort   : bool ;
    eval   : Eval.t ;
    view   : View.t ;
    label  : [ `label of string | `text of string ] ;
    show   : bool ;
    source : IGroup.t option
  >   

type t = SetColumn.t list

val default : t
( *|||| *)(* }}}} *) 


module DiffEval : Ohm.JoyA.FMT with type t = 
  [ `profile of [ `firstname 
		| `lastname 
		| `email 
		| `birthdate
		| `phone
		| `cellphone 
		| `address
		| `zipcode
		| `city
		| `country
		| `gender 
		]
  | `self of  [ `state 
	      | `date 
	      | `field of string ]
  | `named of string * [ `state 
		       | `date 
		       | `field of string ]
  ]

module DiffColumn : Ohm.JoyA.FMT with type t = 
  <
    after : DiffEval.t option ;
    sort  : bool ;
    show  : bool ;
    eval  : DiffEval.t ;
    view  : View.t ;
    label : string ;
  >

module Diff : Ohm.JoyA.FMT with type t = 
  [ `Add of DiffColumn.t 
  | `Remove of DiffEval.t
  | `Refresh
  ]

val names : Diff.t -> (string * string) list

