(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Universal

module Init = Fmt.Make(struct
  type json t = <
    t       : string ;
    ip      : string ;
    query   : string 
  > 
end)

module Answer = Fmt.Make(struct
  type json t = <
    t       : string ;
    id      : Id.t   ;
    ip      : string ;
    values  : (string * string) assoc 
  > 
end)

module MyDB = CouchDB.Convenience.Database(struct let db = O.db "sondage" end)
module InitTable = CouchDB.Table(MyDB)(Id)(Init)
module AnswerTable = CouchDB.Table(MyDB)(Id)(Answer)

let start ~ip ~query = 

  let id = Id.gen () in
  let obj = object
    method t       = "init"
    method ip      = ip
    method query   = query
  end in

  let! _ = ohm $ InitTable.put id obj in
  return $ Id.str id

let partial ~cookie ~name ~value ~ip = 

  let id = Id.gen () in 
  let obj = object
    method t       = "part"
    method id      = Id.of_string cookie
    method ip      = ip
    method values  = [name,value]
  end in

  let! _ = ohm $ AnswerTable.put id obj in
  return () 

let final ~cookie ~list ~ip = 
 
  let id = Id.gen () in
  let obj = object
    method t       = "fini"
    method id      = Id.of_string cookie
    method ip      = ip
    method values  = list
  end in
  
  let! _ = ohm $ AnswerTable.put id obj in
  return () 


