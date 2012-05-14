(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

module PreConfig = struct

  module TemplateVersionCreate = struct
      
    module Fields = struct
	
      type config = <
        template_name : ITemplate.t -> I18n.text ;
        autocomplete  : (string * (string list)) list
      > 

      let  config = object
	method template_name _ = `text ""
	method autocomplete = []
      end
	
      include Fmt.Make(struct
	module ITemplate = ITemplate
	type json t = [ `Diffs | `Applies of ITemplate.t ]
      end)
      
      let fields  = [ `Diffs ]
	
      let details = function 
      
	| `Diffs      -> Form.hidden ~json:(fun _ -> true) ~name:"diffs" ~label:""
	  |> Form.add_config_js begin fun id _ cfg ->
	    Js.Admin.joy id (JoyA.array MPreConfig.TemplateDiff.edit) (cfg # autocomplete)
	  end
	  
	| `Applies t  -> Form.Dyn.checkbox ~name:(ITemplate.to_string t) ~label:(fun c -> c # template_name t)

      let hash = Form.prefixed_name_as_hash "admin-preconfig-templateVersion-create" details
	
    end
      
    module Form = Form.Make(Fields)
      
  end

  module VerticalVersionCreate = struct
      
    module Fields = struct
	
      type config = <
        vertical_name : IVertical.t -> I18n.text ;
        autocomplete  : (string * (string list)) list
      > 

      let  config = object
	method vertical_name _ = `text ""
	method autocomplete = []
      end
	
      include Fmt.Make(struct
	module IVertical = IVertical
	type json t = [ `Diffs | `Applies of IVertical.t ]
      end)
      
      let fields  = [ `Diffs ]
	
      let details = function 
      
	| `Diffs      -> Form.hidden ~json:(fun _ -> true) ~name:"diffs" ~label:""
	  |> Form.add_config_js begin fun id _ cfg ->
	    Js.Admin.joy id (JoyA.array MPreConfig.VerticalDiff.edit) (cfg # autocomplete)
	  end
	  
	| `Applies t  -> let _, name = BatString.replace ~str:(IVertical.to_string t) ~sub:":" ~by:"-" in 
			 Form.Dyn.checkbox ~name ~label:(fun c -> c # vertical_name t)

      let hash = Form.prefixed_name_as_hash "admin-preconfig-verticalVersion-create" details
	
    end
      
    module Form = Form.Make(Fields)
      
  end

end

module Vertical = struct

  module Edit = struct

    module Fields = struct

      type config = <
	autocomplete : (string * (string list)) list
      > ;;

      let config  = object
	method autocomplete = []
      end

      include Fmt.Make(struct
	type json t = [ `Data ]
      end)

      let fields = [ `Data ]

      let details = function
	| `Data -> Form.hidden ~json:(fun _ -> true) ~name:"data" ~label:""
  	  |> Form.add_config_js begin fun id _ cfg ->
	    Js.Admin.joy id MVertical.Edit.edit (cfg # autocomplete)
	  end
	
      let hash = Form.prefixed_name_as_hash "admin-vertical-edit" details

    end

    module Form = Form.Make(Fields)

  end

end

module Template = struct

  module Edit = struct

    module Fields = struct

      type config = <
	autocomplete : (string * (string list)) list
      > ;;

      let config  = object
	method autocomplete = []
      end

      include Fmt.Make(struct
	type json t = [ `Data ]
      end)

      let fields = [ `Data ]

      let details = function
	| `Data -> Form.hidden ~json:(fun _ -> true) ~name:"data" ~label:""
  	  |> Form.add_config_js begin fun id _ cfg ->
	    Js.Admin.joy id MVertical.Template.Edit.edit (cfg # autocomplete)
	  end
	
      let hash = Form.prefixed_name_as_hash "admin-template-edit" details

    end

    module Form = Form.Make(Fields)

  end

end

module MakeAdmin = struct
      
  module Fields = struct
      
    type config = unit
    let  config = ()
	
    include Fmt.Make(struct
      type json t = [ `Email | `Instance ] 
    end)
      
      let fields  = [ `Email ; `Instance ]
	
      let details = function 
	| `Instance -> Form.text ~name:"instance" ~label:"instance.field.key"
	| `Email    -> Form.text ~name:"email"    ~label:"login.signup-form.login"
	      
      let hash = Form.prefixed_name_as_hash "admin-make" details
	
  end
    
  module Form = Form.Make(Fields)
      
end

module I18n = struct
      
  module Fields = struct
      
    type config = unit
    let  config = ()
	
    include Fmt.Make(struct
      type json t = [ `Source ] 
    end)
      
      let fields  = [ `Source ]
	
      let details = function 
      
	| `Source      -> Form.hidden ~json:(fun _ -> true) ~name:"source" ~label:""
	  |> Form.add_js begin fun id _ ->
	    JsCode.make
	      ~name:"admin.joy"
	      ~args:[ Id.to_json id ;
		      JoyA.Node.to_json I18n.Source.edit ;
		      Json_type.Build.objekt []
		    ]
	  end
	      
      let hash = Form.prefixed_name_as_hash "admin-i18n" details
	
  end
    
  module Form = Form.Make(Fields)
      
end

