(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives

type field = <
  name : string ;
  valid : [`max of int | `required] list ;
  edit : [ `textarea 
	 | `longtext 
	 | `date
	 | `checkbox
	 | `picture
	 | `pickOne of I18n.text list
	 | `pickMany of I18n.text list
	 | `hide ]
> ;;

let render ( field : field ) instance (id:Id.t) (i18n:I18n.t) ctx = 

  let data = object 
    method id = id
    method name = field # name 
  end in 

  let list_of_values l = 
    l |> BatList.mapi begin fun i item -> 
      match item with `text "" -> None | text ->
	Some (object
	  method id    = id
	  method name  = field # name
	  method value = i
	  method label = text
	end)
    end |> BatList.filter_map identity 	 
  in

  match field # edit with 
    | `textarea   -> VField.Textarea.render data i18n ctx
    | `longtext   -> VField.LongText.render data i18n ctx
    | `date       -> VField.Date.render     data i18n ctx
    | `checkbox   -> VField.Checkbox.render data i18n ctx

    | `hide       -> ctx

    | `pickOne  l -> VField.PickOne.render (list_of_values l) i18n ctx
    | `pickMany l -> VField.PickMany.render (list_of_values l) i18n ctx

    | `picture    -> CFile.client_pic_uploader instance i18n id (field # name) ctx

let initialize i18n cuid edit raw = 
  match edit with 
    | `longtext
    | `textarea 
    | `checkbox
    | `pickOne  _ 
    | `hide -> raw

    | `picture -> ( match raw with 
	| Json_type.String s -> 
	  (* This is a picture in an users or entity's join form... *)
	  let id = IFile.of_string s |> IFile.Assert.get_pic in
	  (CFile.get_pic_fmt cuid).Fmt.to_json id
	| _ -> Json_type.Null )

    | `pickMany _ -> ( match raw with
	| Json_type.Array _ -> raw 
	| _ -> Json_type.Array [] )

    | `date -> ( match raw with
	| Json_type.String s -> (MFmt.date (I18n.language i18n)).Fmt.to_json s
	| other -> other )
