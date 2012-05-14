(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal
  
module ValueFmt = Fmt.Make(struct
  type json t = string list
end)

let () = CAdmin_common.register UrlAdmin.extract_cookie begin fun i18n user request response ->

  let fail = return response in 

  let! key   = req_or fail (request # post "key") in
  let! value = req_or fail (request # post "value") in

  let name = "EXTRACT_" ^ String.uppercase key in

  let current_cookie = BatOption.default "[]" 
    (request # cookie name)
  in

  let current_list = BatOption.default []
    (ValueFmt.of_json_string_safe current_cookie) 
  in
  
  let new_list = if List.mem value current_list then current_list else
      BatList.take 3 (value :: current_list)
  in
  
  let new_cookie = ValueFmt.to_json_string new_list in
  
  return $ O.Action.with_cookie ~name ~value:new_cookie ~life:3600 response

end

