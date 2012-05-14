(* © 2012 RunOrg *)

module Index : Ohm.Template.TEXT with type t =
  Ohm.View.Context.text Ohm.View.t

module PreConfig : sig

  module Index : sig

    module Template : Ohm.Template.HTML with type t = 
      < url : string ; edit : string ; name : Ohm.I18n.text ; id : string ; kind : MEntityKind.t > 

    module Vertical : Ohm.Template.HTML with type t = 
      < url : string ; edit : string ; name : Ohm.I18n.text ; id : string ; archive : bool >

    module Page : Ohm.Template.HTML with type t = 
      < 
        verticals : Vertical.t list ; 
        templates : Template.t list ;
	new_vertical : string ;
	new_template : string ;
	new_tmpl_version : string ;
	new_vert_version : string ;
      > 

  end

  module Vertical : Ohm.Template.HTML with type t = 
    <
      name : Ohm.I18n.text ;
      desc : Ohm.I18n.text ;
      url   : string ;
      config: FAdmin.Vertical.Edit.Fields.config ;
      init  : FAdmin.Vertical.Edit.Form.t
    >

  module Template : Ohm.Template.HTML with type t = 
    <
      name : Ohm.I18n.text ;
      desc : Ohm.I18n.text ;
      url   : string ;
      config: FAdmin.Template.Edit.Fields.config ;
      init  : FAdmin.Template.Edit.Form.t
    >

  module TemplateVersion : sig

    module Checkbox : Ohm.Template.HTML with type t = 
      < 
	input : Ohm.View.Context.box Ohm.View.t ; 
        label : Ohm.View.Context.box Ohm.View.t ; 
	kind : MEntityKind.t
      >

    module Create : Ohm.Template.HTML with type t =
      <
	checkboxes : Checkbox.t list ;
        url        : string ;
	init       : FAdmin.PreConfig.TemplateVersionCreate.Form.t ;
        config     : FAdmin.PreConfig.TemplateVersionCreate.Fields.config ;
	dynamic    : FAdmin.PreConfig.TemplateVersionCreate.Fields.t list ;
      >

  end

  module VerticalVersion : sig

    module Checkbox : Ohm.Template.HTML with type t = 
      < 
	input : Ohm.View.Context.box Ohm.View.t ; 
        label : Ohm.View.Context.box Ohm.View.t ; 
	archive : bool
      >

    module Create : Ohm.Template.HTML with type t =
      <
	checkboxes : Checkbox.t list ;
        url        : string ;
	init       : FAdmin.PreConfig.VerticalVersionCreate.Form.t ;
        config     : FAdmin.PreConfig.VerticalVersionCreate.Fields.config ;
	dynamic    : FAdmin.PreConfig.VerticalVersionCreate.Fields.t list ;
      >

  end

end

module I18n : Ohm.Template.HTML with type t = 
  < url : string ; init : FAdmin.I18n.Form.t > 

module MakeAdmin : Ohm.Template.HTML with type t = 
  < url : string >
