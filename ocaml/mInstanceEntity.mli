(* © 2012 MRunOrg *)

module Create : Ohm.JoyA.FMT with type t = 
  <
    name : string ;
    template : ITemplate.t ;
  >

module Update : Ohm.JoyA.FMT with type t = 
  <
    name : string ;
    title : string option ;
    public : bool option ;
    draft  : bool option ;
    data : (string * string) list
  >

module Config : Ohm.JoyA.FMT with type t = 
  <
    name   : string ;
    diffs  : MEntityConfig.Diff.t list
  >

module Diff : Ohm.JoyA.FMT with type t = 
  [ `Create of Create.t 
  | `Update of Update.t
  | `Config of Config.t
  ]

val names : Diff.t -> (string * string) list

type 'a update =  
       ?draft:bool 
    -> ?public:bool 
    -> ?name:Ohm.I18n.text option 
    -> ?data:(string * Json_type.t) list
    -> ?config:MEntityConfig.Diff.t list
    -> unit 
    -> 'a

val update : [ `Update of Update.t | `Config of Config.t ] list -> 'a update -> 'a 

