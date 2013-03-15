(* © 2013 RunOrg *)

val text : 
      label:('c,string) Ohm.Run.t
  -> ?left:bool
  -> ?detail:('c,string) Ohm.Run.t
  ->  ('s -> ('c,string) Ohm.Run.t)
  ->  (OhmForm.field -> string -> ('c,('r,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  ->  ('c,'s,'r) OhmForm.template

val textarea : 
      label:('c,string) Ohm.Run.t
  -> ?detail:('c,string) Ohm.Run.t
  ->  ('s -> ('c,string) Ohm.Run.t)
  ->  (OhmForm.field -> string -> ('c,('r,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  ->  ('c,'s,'r) OhmForm.template

val rich : 
      label:('c,string) Ohm.Run.t
  -> ?detail:('c,string) Ohm.Run.t
  ->  ('s -> ('c,string) Ohm.Run.t)
  ->  (OhmForm.field -> string -> ('c,('r,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  ->  ('c,'s,'r) OhmForm.template

val date : 
      label:('c,string) Ohm.Run.t
  -> ?detail:('c,string) Ohm.Run.t
  ->  ('s -> ('c,string) Ohm.Run.t)
  ->  (OhmForm.field -> string -> ('c,('r,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  ->  ('c,'s,'r) OhmForm.template

val picker : 
      label:('c,string) Ohm.Run.t
  -> ?left:bool
  -> ?detail:('c,string) Ohm.Run.t
  ->  format:'data Ohm.Fmt.fmt 
  -> ?static:('data * string * ('c,Ohm.Html.writer) Ohm.Run.t) list 
  ->  ('s -> ('c,'data list) Ohm.Run.t)
  ->  (OhmForm.field -> 'data list -> ('c,('r,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  ->  ('c,'s,'r) OhmForm.template

module Picker : sig 
  
  module QueryFmt : Ohm.Fmt.FMT with type t = [ `ByJson of Ohm.Json.t list | `ByPrefix of string ] 

  val formatResults : 
        'data Ohm.Fmt.fmt
    -> ('data * ('c, Ohm.Html.writer) Ohm.Run.t) list  
    -> ('c, (string * Ohm.Json.t) list) Ohm.Run.t

end

val radio : 
      label:('ctx,string) Ohm.Run.t
  -> ?detail:('ctx,string) Ohm.Run.t
  ->  format:'data Ohm.Fmt.fmt 
  ->  source:('data * ('ctx,Ohm.Html.writer) Ohm.Run.t) list 
  ->  ('seed -> ('ctx,'data option) Ohm.Run.t)
  ->  (OhmForm.field -> 'data option -> ('ctx,('result,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  ->  ('ctx,'seed,'result) OhmForm.template    

val checkboxes : 
      label:('ctx,string) Ohm.Run.t
  -> ?detail:('ctx,string) Ohm.Run.t
  ->  format:'data Ohm.Fmt.fmt 
  ->  source:('data * ('ctx,Ohm.Html.writer) Ohm.Run.t) list 
  ->  ('seed -> ('ctx,'data list) Ohm.Run.t)
  ->  (OhmForm.field -> 'data list -> ('ctx,('result,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  ->  ('ctx,'seed,'result) OhmForm.template    
    
val with_ok_button : 
     ok:('c,string) Ohm.Run.t
  -> ('c,'s,'r) OhmForm.template
  -> ('c,'s,'r) OhmForm.template

