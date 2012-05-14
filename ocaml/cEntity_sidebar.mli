(* © 2012 RunOrg *)

type info = <
  picture   : string option ;
  name      : Ohm.I18n.text ;
  url_asso  : string ;
  name_asso : string ;
  url_list  : string ;
  kind      : MEntityKind.t ;
  desc      : Ohm.I18n.text ;
  join      : Ohm.I18n.t -> Ohm.View.html ;
  invited   : bool ;
  eid       : IEntity.t
> ;;

val tabs :
     'a CContext.full
  -> (('prefix * UrlSegs.entity_tabs) O.Box.box_context -> info)
  -> ('prefix * UrlSegs.entity_tabs) O.box
  -> UrlSegs.entity_tabs
  -> (UrlSegs.entity_tabs * ('prefix * UrlSegs.entity_tabs) O.box) list
  -> 'prefix O.box
  
