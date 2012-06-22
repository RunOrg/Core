(* © 2012 RunOrg *)

val radio : 
     label:('ctx,string) Ohm.Run.t
  -> detail:('ctx,string) Ohm.Run.t
  -> format:'data Ohm.Fmt.fmt 
  -> source:('data * ('ctx,Ohm.Html.writer) Ohm.Run.t) list 
  -> ('seed -> ('ctx,'data option) Ohm.Run.t)
  -> (OhmForm.field -> 'data option -> ('ctx,('result,OhmForm.field * string) BatStd.result) Ohm.Run.t)
  -> ('ctx,'seed,'result) OhmForm.template    
    
val with_ok_button : 
     ok:('c,string) Ohm.Run.t
  -> ('c,'s,'r) OhmForm.template
  -> ('c,'s,'r) OhmForm.template

