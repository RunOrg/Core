(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type t = <
  firstname : string ; 
  initials  : string ; 
  body      : string ;
  picture   : string option ; 
>

module Item = struct
  module T = struct
    type json t = {
      firstname : string ; 
      initials  : string ; 
      body      : string ; 
      time      : float ;
     ?picture   : string option ; 
      show      : bool ;
    }
  end
  include T
  include Fmt.Extend(T) 
end

include CouchDB.Convenience.Table(struct let db = O.db "voeux" end)(IUser)(Item)

module AllView = CouchDB.DocView(struct
  module Key    = Fmt.Unit
  module Value  = Fmt.Unit
  module Doc    = Item 
  module Design = Design 
  let name = "all"
  let map = "if (doc.show && doc.body && doc.firstname && doc.initials) emit(doc.time)"
end)

let publish time t = 
  let clip n s = 
    let s = BatString.strip s in
    if String.length s > n then BatString.head s n else s
  in 
  let firstname = clip 30  (t # firstname) in
  let initials  = clip 30  (t # initials)  in
  let body      = clip 500 (t # body) in
  let picture   = t # picture in 
  function 
    | None -> Item.({ firstname ; initials ; body ; time ; picture ; show = true })
    | Some i -> Item.({ i with firstname ; initials ; picture ; body }) 

let set uid t = 
  let! now = ohmctx (#time) in
  Tbl.replace (IUser.decay uid) (publish now t) 

let extract i = Item.(object
  method firstname = i.firstname
  method initials  = i.initials
  method body      = i.body 
  method picture   = i.picture
end)

let get uid = 
  let! i = ohm_req_or (return None) $ Tbl.get (IUser.decay uid) in
  return $ Some (extract i) 

let all () = 
  let! list = ohm $ AllView.doc_query () in
  return (List.rev_map (#doc |- extract) list) 
