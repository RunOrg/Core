(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module ByOwnerView = CouchDB.DocView(struct
  module Key = Id
  module Value = Fmt.Unit
  module Doc = Line
  module Design = Design
  let name = "by_owner"
  let map = "emit(doc.owner[1])"
end)

let get_or_create owner = 

  let id = IInboxLineOwner.to_id owner in 
  
  let! found_opt = ohm (ByOwnerView.doc id |> Run.map Util.first) in
  
  match found_opt with 
    | Some item -> return (IInboxLine.of_id (item # id))
    | None -> (* Line missing, create one *)
      
      let line = Line.({
	owner  = IInboxLineOwner.decay owner ;
	show   = false ;
	time   = 0.0 ;
	push   = 0 ; 
	album  = None ;
	folder = None ;
	wall   = None ;
      }) in
      
      Tbl.create line
	
