(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let li (endpoint, data) = 
  Asset_More_Auto.render (object
    method el       = "li"
    method endpoint = JsCode.Endpoint.to_json endpoint
    method data     = data
  end) 

let div (endpoint, data) = 
  Asset_More_Auto.render (object
    method el       = "div"
    method endpoint = JsCode.Endpoint.to_json endpoint
    method data     = data
  end) 


