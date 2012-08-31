(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

let status_url access exid = 
  Action.url UrlClient.Export.status (access # instance # key) 
    (IExport.decay exid,
     IExport.Deduce.make_read_token (access # isin |> IIsIn.user) exid)

let download_url access exid =  
  Action.url UrlClient.Export.status (access # instance # key) 
    (IExport.decay exid,
     IExport.Deduce.make_read_token (access # isin |> IIsIn.user) exid)
    
