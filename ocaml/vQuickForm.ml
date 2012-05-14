(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open Ohm.Template
open BatPervasives

module Loader = MModel.Template.MakeLoader(struct let from = "quick-form" end)

let field_sel = ".joy-fields"

let parse_trimmed parse i18n field string = 
  let string = BatString.trim string in 
  parse i18n field (if string = "" then None else Some string)

(* ------------------------------------------------------------------------------- *)

module MiniField = Loader.Html(struct
  type t = unit
  let source  _ = "mini-field"
  let mapping _ = []
end)

let mini_select ~format ~source init parse = 
  let inner = 
    Joy.select
      ~field:""
      ~format
      ~source
      init
      parse
  in
  Joy.wrap field_sel (MiniField.render ()) inner

(* ------------------------------------------------------------------------------- *)

module FieldArray = Loader.Html(struct
  type t = <
    minitip: I18n.text option ;
    add: I18n.text ;
    label: I18n.text 
  > ;;
  let source  _ = "field-array"
  let mapping _ = [
    "minitip", Mk.trad (fun x -> BatOption.default (`text "") (x # minitip)) ;
    "add",     Mk.trad (#add) ;
    "label",   Mk.trad (#label) ;
    "item",    Mk.str  (fun _ -> "")
  ]    
end)

module FieldArrayItem = Loader.Html(struct
  type t = unit
  let source  _ = "field-array/item"
  let mapping _ = []
end)

let fieldArray ~add ~label ?minitip inner = 
  let array =  
    Joy.array 
      ~list:"ul"
      ~add:".-add"
      ~remove:".-remove"
      ~item:(FieldArrayItem.render ())
      inner
  in
  Joy.wrap field_sel
    (FieldArray.render (object
      method minitip = minitip
      method add = add
      method label = label 
    end)) array

(* ------------------------------------------------------------------------------- *)

let fieldOption ~add ~label ?minitip inner = 
  let option =  
    Joy.option 
      ~list:"ul"
      ~add:".-add"
      ~remove:".-remove"
      ~item:(FieldArrayItem.render ())
      inner
  in
  Joy.wrap field_sel
    (FieldArray.render (object
      method minitip = minitip
      method add = add
      method label = label 
    end)) option

(* ------------------------------------------------------------------------------- *)

module Textarea = Loader.Html(struct
  type t = <
    minitip  : I18n.text option ;
    required : bool ;
    tall     : bool ;
  > ;;
  let source  _ = "textarea"
  let mapping _ = [
    "minitip",  Mk.trad (fun x -> BatOption.default (`text "") (x # minitip)) ;
    "required", Mk.str  (fun x -> if x # required then " required" else "") ;
    "tall",     Mk.str  (fun x -> if x # tall then " -tall" else "") ;
  ]
end)

let textarea ~label ?(required=false) ?(tall=false) ?minitip init parse = 
  let inner = 
    Joy.string 
      ~field:"textarea"
      ~label:(".-label label",label)
      ~error:".-error label"
      init
      (parse_trimmed parse)
  in
  Joy.wrap field_sel 
    (Textarea.render (object 
      method minitip  = minitip
      method required = required
      method tall     = tall
    end)) inner						     

(* ------------------------------------------------------------------------------- *)

module DateTime = Loader.Html(struct
  type t = <
    minitip  : I18n.text option ;
  > ;;
  let source  _ = "datetime"
  let mapping _ = [
    "minitip",  Mk.trad (fun x -> BatOption.default (`text "") (x # minitip)) ;
  ]
end)

let datetime ~label ?(ancient=false) ?minitip init = 

  let minsnap t = 5 * ((t / 5) mod 12) in

  let render i18n ctx = 
    DateTime.render (object 
      method minitip  = minitip
    end) i18n ctx
    |> View.Context.add_js_code (Js.datepicker "input" ~ancient ~lang:(I18n.language i18n))
  in
  
  Joy.begin_object (fun ~date ~hour ~minute -> 
    date +. 60. *. ( float_of_int minute +. 60. *. float_of_int hour )) 

  |> Joy.append (fun f date -> f ~date)
      (Joy.string 
	 ~field:"input"
	 ~label:(".-label label",label)
	 ~error:".-error label"      
	 (fun i18n datetime -> 
	   let date = MFmt.date_of_float datetime in
	   BatOption.default ""
	     (MFmt.format_date (I18n.language i18n) date))
	 (fun i18n field string -> 
	   let date = MFmt.unformat_date (I18n.language i18n) string in
	   let time = BatOption.bind MFmt.float_of_date date in
	   match time with 
	     | Some time -> Ok time
	     | None      -> Bad (field, `label "field.required")))

  |> Joy.append (fun f hour -> f ~hour)
      (Joy.string ~field:"select.-h" 
	 (fun i18n datetime -> 
	     let tm = Unix.localtime datetime in
	     string_of_int tm.Unix.tm_hour)
	 (fun i18n field data -> 
	   Ok (try int_of_string data with _ -> 0))) 

  |> Joy.append (fun f minute -> f ~minute) 
      (Joy.string ~field:"select.-m" 
	 (fun i18n datetime -> 
	     let tm = Unix.localtime datetime in
	     string_of_int (minsnap tm.Unix.tm_min))
	 (fun i18n field data -> 
	   Ok (try int_of_string data with _ -> 0)))
  |> Joy.end_object ~html:(field_sel,render)
  |> Joy.seed_map init       

(* ------------------------------------------------------------------------------- *)

module Input = Loader.Html(struct
  type t = <
    minitip  : I18n.text option ;
    required : bool ;
    large    : bool ;
  > ;;
  let source  _ = "input"
  let mapping _ = [
    "minitip",  Mk.trad (fun x -> BatOption.default (`text "") (x # minitip)) ;
    "required", Mk.str  (fun x -> if x # required then " required" else "") ;
    "size",     Mk.str  (fun x -> if x # large then "large-input" else "") ;
  ]
end)

let select ~label ?(required=false) ?minitip ~format ~source init parse = 
  let inner = 
    Joy.select
      ~field:"input"
      ~label:(".-label label",label)
      ~error:".-error label"
      ~format
      ~source
      init
      parse
  in
  Joy.wrap field_sel 
    (Input.render (object
      method minitip = minitip
      method required = required
      method large = false
    end)) inner

module Choice = Loader.Html(struct
  type t = <
    minitip  : I18n.text option 
  > ;;
  let source  _ = "choice"
  let mapping _ = [
    "minitip",  Mk.trad (fun x -> BatOption.default (`text "") (x # minitip)) ;
  ]
end)

let choice ~label ?(required=false) ?minitip ~format ~source ~multiple init parse = 
  let inner = 
    Joy.choice
      ~field:".-pick"
      ~label:(".-label label",label)
      ~error:".-error label"
      ~format
      ~source
      ~multiple
      init
      parse
  in
  Joy.wrap field_sel 
    (Choice.render (object
      method minitip = minitip
    end)) inner

let longinput ~label ?(required=false) ?minitip init parse = 
  let inner = 
    Joy.string 
      ~field:"input"
      ~label:(".-label label",label)
      ~error:".-error label"
      init
      (parse_trimmed parse)
  in
  Joy.wrap field_sel 
    (Input.render (object 
      method minitip  = minitip
      method required = required
      method large    = true
    end)) inner						     

let input ~label ?(required=false) ?minitip init parse = 
  let inner = 
    Joy.string 
      ~field:"input"
      ~label:(".-label label",label)
      ~error:".-error label"
      init
      (parse_trimmed parse)
  in
  Joy.wrap field_sel 
    (Input.render (object 
      method minitip  = minitip
      method required = required
      method large    = false
    end)) inner	

let date ~label ?(required=false) ?(ancient=false) ?minitip init parse = 
  let inner = 
    Joy.string 
      ~field:"input"
      ~label:(".-label label",label)
      ~error:".-error label"      
      (fun i18n data -> 
	BatOption.default ""
	  (BatOption.bind (MFmt.format_date (I18n.language i18n))
	     (init i18n data)))
      (fun i18n field data ->
	parse i18n field (MFmt.unformat_date (I18n.language i18n) data))
  in
  
  let render i18n ctx = 
    Input.render (object 
      method minitip  = minitip
      method required = required
      method large    = false
    end) i18n ctx
    |> View.Context.add_js_code (Js.datepicker "input" ~ancient ~lang:(I18n.language i18n))
  in

  Joy.wrap field_sel render inner
    
	
(* ------------------------------------------------------------------------------- *)

module Wrap = Loader.Html(struct
  type t = <
    submit : I18n.text ;
    cancel : I18n.text ;
    cancel_url : string
  > ;;
  let source  _ = "wrap"
  let mapping _ = [
    "submit",     Mk.trad (#submit) ;
    "cancel",     Mk.trad (#cancel) ;
    "cancel-url", Mk.esc  (#cancel_url)
  ]
end)

let full_wrap ~submit ~cancel t = 
  Joy.wrap Joy.here (Wrap.render (object
    method submit = submit
    method cancel = fst cancel
    method cancel_url = snd cancel
  end)) t

module SaveWrap = Loader.Html(struct
  type t = <
    submit : I18n.text ;
  > ;;
  let source  _ = "save-wrap"
  let mapping _ = [
    "submit",     Mk.trad (#submit) ;
  ]
end)

let save_wrap ~submit t = 
  Joy.wrap Joy.here (SaveWrap.render (object
    method submit = submit
  end)) t

let wrap ~submit ?cancel t = 
  match cancel with 
    | None -> save_wrap ~submit t
    | Some cancel -> full_wrap ~submit ~cancel t

(* ------------------------------------------------------------------------------- *)

module NarrowWrap = Loader.Html(struct
  type t = <
    submit : I18n.text ;
  > ;;
  let source  _ = "narrow-save-wrap"
  let mapping _ = [
    "submit",     Mk.trad (#submit) ;
  ]
end)

let narrow_wrap ~submit t = 
  Joy.wrap Joy.here (NarrowWrap.render (object
    method submit = submit
  end)) t

