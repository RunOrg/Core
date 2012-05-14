(* © 2012 Runorg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyTable = MFile_common.MyTable

let build_key version id name = 
  String.concat "/" [
    IFile.to_string id ;
    MFile_common.string_of_version version ;
    name
  ]

let get file version = 
  
  let id = IFile.decay file in 
  
  let! file = ohm_req_or (return None) $ MyTable.get id in

  let versionData_opt = 
    try Some (List.assoc (MFile_common.string_of_version version) (file # versions))
    with Not_found -> None
  in
  
  let! versionData = req_or (return None) versionData_opt in

  let name = versionData # name in 

  return begin    
    match file # k with 
      | `Temp    -> None
      | `Image 
      | `Doc     -> Some (ConfigS3.qsa_auth 
			    ~bucket:"ro-files"
			    ~key:(build_key version id name)
			    ~duration:3600)
      | `Extern  -> Some name
      | `Picture -> Some ("http://ro-pics.s3.amazonaws.com/" ^ build_key version id name)
  end
