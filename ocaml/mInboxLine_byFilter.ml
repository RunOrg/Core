(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MInboxLine_common

module ByFilterView = CouchDB.DocView(struct
  module Key = IInboxLine.Filter
  module Value = Fmt.Unit
  module Doc = Line
  module Design = Design
  let name = "by_filter"
  let map = "for (var i = 0; i < doc.filter.length; ++i)
               if (doc.filter[i].length > 1) 
                 emit(doc.filter[i])"
end)

let all ?start ~count filter = 
  let  startkey = filter in
  let  endkey   = filter in 
  let  limit    = count + 1 in 
  let  startid  = BatOption.map IInboxLine.to_id start in 
  let! list = ohm 
    (ByFilterView.doc_query ~startkey ~endkey ?startid ~descending:true ~limit ~endinclusive:true ()) in

  let  list, next = OhmPaging.slice ~count list in 
  let  next = BatOption.map (#id %> IInboxLine.of_id) next in 
  let  list = List.map (fun i -> IInboxLine.of_id (i#id), i # doc) list in
  return (list, next) 

