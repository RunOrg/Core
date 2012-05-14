(* © 2012 RunOrg *)

module Status : Ohm.Template.TEXT with type t = MMembership.Status.t

module Self : sig

  module YesNoCancelButtons : Ohm.Template.HTML with type t = 
    <
      status : Ohm.I18n.text ;
      yes    : Ohm.I18n.text ;
      no     : Ohm.I18n.text ; 
      no_js  : Ohm.JsCode.t ;
    > ;;

  module YesCancelButtons : Ohm.Template.HTML with type t = 
    <
      status : Ohm.I18n.text ;
      yes    : Ohm.I18n.text ;
    > ;;

  module NoCancelButtons : Ohm.Template.HTML with type t = 
    <
      status : Ohm.I18n.text ;
      no     : Ohm.I18n.text ; 
      no_js  : Ohm.JsCode.t ;
    > ;;

  val render_buttons : 
       ?yes:Ohm.I18n.text
    -> ?no:(Ohm.I18n.text * Ohm.JsCode.t)
    -> Ohm.I18n.text
    -> Ohm.I18n.t
    -> Ohm.View.html 

  module Form : Ohm.Template.HTML with type t = Ohm.I18n.t -> Ohm.View.html

end

module Button : sig

  val render : MMembership.Status.t -> string -> Ohm.I18n.t -> Ohm.View.html

end

module Manage : sig

  type action = <
    time    : float ;
    name    : string ;
    picture : string ;
    profile : string
  > ;;

  module Validation_Write : Ohm.Template.HTML with type t = 
    <
      yes : Ohm.JsCode.t ;
      no  : Ohm.JsCode.t 
    > ;;

  module Validation_Read : Ohm.Template.HTML with type t = 
    Ohm.JsCode.t * bool * action option

  module Validation : Ohm.Template.HTML with type t = 
    <
      action : action option ;
      status : bool ;
      yes    : Ohm.JsCode.t ;
      no     : Ohm.JsCode.t ;
      edit   : Ohm.JsCode.t 
    > ;;

  module Member_Write : Ohm.Template.HTML with type t = 
    <
      yes : Ohm.JsCode.t ;
      no  : Ohm.JsCode.t 
    > ;;

  module Member_Read : Ohm.Template.HTML with type t = 
    Ohm.JsCode.t option * bool * action option

  module Member : Ohm.Template.HTML with type t =
    < 
      action : (bool * action) option ;
      edit   : Ohm.JsCode.t option ;
      yes    : Ohm.JsCode.t ;
      no     : Ohm.JsCode.t ;
    > ;;

  module Invite_Details : Ohm.Template.HTML with type t = action

  module Invite : Ohm.Template.HTML with type t = 
    <
      action : action option ;
      invite : Ohm.JsCode.t option
    > ;;
    
  module Data_Item : Ohm.Template.HTML with type t = 
    Ohm.I18n.text * (Ohm.I18n.t -> Ohm.View.html) 

  module Data : Ohm.Template.HTML with type t = 
    <
      items : Data_Item.t list ;
      edit  : Ohm.JsCode.t
    > ;;

  module Page : Ohm.Template.HTML with type t = 
    <
      back    : string ;
      picture : string ;
      profile : string ;
      name    : string ;
      status  : VStatus.t ;
      join    : MMembership.Status.t ;
      admin   : Validation.t ;
      member  : Member.t ;
      invite  : Invite.t option ;
      data    : Data.t option 
    > ;;

end
