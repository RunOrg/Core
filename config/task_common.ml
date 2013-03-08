(* © 2013 RunOrg *)

open Common

type fieldtype = 
  [ `TextShort
  | `TextLong
  | `PickOne  of (string * adlib) list
  | `PickMany of (string * adlib) list
  | `Date
  ]

type stateset = {
  ss_name : string ;
  ss_list : (string * adlib * bool) list ;
}

let statesets = ref []

let states name list = 
  statesets := 
    { ss_name = name ;
      ss_list = List.map (fun (key, label, final) -> 
	key, adlib ("Task_State_" ^ name ^ "_" ^ key) label, final) list }
  :: !statesets ; 
  name

type field = {
  f_name : string ;
  f_label : adlib ;
  f_type : fieldtype
}

let fields = ref []

let field name label kind = 
  fields := 
    { f_name = name ; 
      f_label = adlib ("Task_Field_" ^ name) label ;
      f_type = kind }
  :: !fields ;
  name

type process = {
  p_key : string ;
  p_label : adlib ; 
  p_context : string ; 
  p_stateset : string ;
  p_fields : string list ;
}

let processes = ref []

let process key context stateset label fields = 
  processes := 
    { p_key = key ;
      p_label = adlib ("Task_Process_" ^ key) label ;
      p_context = context ;
      p_stateset = stateset ;
      p_fields = fields }
  :: !processes
