(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal 
open BatPervasives

let status_url access exid = 
  Action.url UrlClient.Export.status (access # instance # key) 
    (IExport.decay exid,
     IExport.Deduce.make_read_token (access # isin |> IIsIn.user) exid)

let download_url cuid key exid =  
  Action.url UrlClient.Export.download key 
    (IExport.decay exid,
     IExport.Deduce.make_read_token cuid exid)
    
let () = UrlClient.Export.def_status begin fun req res -> 

  let  fail = return res in 
  let! cuid, key, _, _ = CClient.extract_ajax req res in 
  let! cuid = req_or fail cuid in 
  
  let  exid, proof = req # args in 
  let! exid = req_or fail (IExport.Deduce.from_read_token cuid exid proof) in  

  let! did, total = ohm_req_or fail (MCsvExport.progress (IExport.decay exid)) in

  let result = [ "progress", Json.Float (float_of_int did /. float_of_int total) ] in

  let! finished = ohm_req_or fail (MCsvExport.finished (IExport.decay exid)) in 

  let result = 
    if finished then 
      let url = download_url cuid key exid in       
      ( "url", Json.String url ) :: result
    else 
      result
  in

  return $ Action.json result res

end 

let () = UrlClient.Export.def_download begin fun req res -> 
  
  let  fail = return res in 
  let! cuid, _, _, _ = CClient.extract req res in 
  let! cuid = req_or fail cuid in 
  
  let  exid, proof = req # args in 
  let! exid = req_or fail (IExport.Deduce.from_read_token cuid exid proof) in  

  let! data = ohm_req_or fail (MCsvExport.download exid) in 
  
  return $ Action.file ~file:"list.csv" ~mime:"text/csv" ~data res

end 
