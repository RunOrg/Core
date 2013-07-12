(* © 2013 RunOrg *)

type edit = <
  title : string ;
  body  : MRich.OrText.t ;
>

val template : unit -> (#O.ctx, [`Admin] MNewsletter.t option, edit) OhmForm.template
