(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module MyDB     = CouchDB.Convenience.Database(struct let db = O.db "poll" end)
module MyUnique = OhmCouchUnique.Make(MyDB)
module Design   = struct
  module Database = MyDB
  let name = "poll"
end

module Data = Fmt.Make(struct
  type json t = <
    t         : MType.t ;
    questions : TextOrAdlib.t list ;
    answers   : int list ;
    multiple  : bool ;
    total     : int 
  > 
end)

module Tbl = CouchDB.Table(MyDB)(IPoll)(Data)

type details = <
  questions : TextOrAdlib.t list ;
  multiple : bool
> ;;

type stats = <
  answers : (TextOrAdlib.t * int) list ;
  total : int ;
> ;;

type 'relation t = Data.t

let create details = 

  let clip n s = if String.length s > n then String.sub s 0 n else s in      

  let obj = object
    method t         = `Poll
    method questions = List.map 
      (function `label l -> `label l | `text t -> `text (clip 80 t)) (details # questions)
    method answers   = [] 
    method multiple  = details # multiple
    method total     = 0
  end in

  let! id = ohm $ Tbl.create obj in 

  (* Poll was created right above. *)
  return (IPoll.Assert.created id)
		     
let get id = 
  Tbl.get (IPoll.decay id)

module Get = struct

  let details t = (t :> details)

  let stats t = object
    method total   = t # total 
    method answers = 
      let rec aux = function 
	| (hq :: tq) , (ha :: ta) -> (hq , ha) :: aux (tq , ta)
	| (hq :: tq) , []         -> (hq , 0)  :: aux (tq , []) 
	| _                       -> []
      in aux (t # questions , t # answers) 
  end

end

module Result = Fmt.Make(struct
  type json t = <
    total   "t" : int ;
    answers "a" : int list 
  > 
end)

module RecapView = CouchDB.ReduceView(struct
  module Key = IPoll
  module Value = Result
  module Reduced = Result
  module Design = Design
  let name = "collect"
  let map  = "if (doc.t == 'pans') {
                var a = [];
                for (var k in doc.a) a[doc.a[k]] = 1;
                emit(doc.p,{t:1,a:a});
              }" 
  let group = true
  let level = None
  let reduce = "var r = {t:0,a:[]};
                for (var i in values) { 
                  r.t += values[i].t; 
                  for (var k in values[i].a) {
                    r.a[k] = values[i].a[k] + (k < r.a.length ? r.a[k] : 0);
                  }
                }
                return r;" 
end)

let empty = object
  method total   = 0
  method answers = []
end 

let refresh id =   

  let id = IPoll.decay id in

  let updated data stats = 
    if stats # total = data # total && stats # answers = data # answers 
    then (), `keep
    else (), `put (object
      method t         = `Poll
      method questions = data # questions
      method multiple  = data # multiple
      method total     = stats # total
      method answers   = stats # answers
    end)
  in

  let refresh = function 
    | Some data ->
      RecapView.reduce id |> Run.map (BatOption.default empty) |> Run.map (updated data)
    | None -> return ((), `keep)
  in

  Tbl.transact id refresh

module Answer = struct

  module Answer = Fmt.Make(struct
    type json t = <
      t           : MType.t ;
      who "w"     : IAvatar.t ;
      answers "a" : int list ;
      poll "p"    : IPoll.t
    > 
  end)

  module AnswerTable = CouchDB.Table(MyDB)(Id)(Answer)

  let key avatar poll = 
    OhmCouchUnique.pair (IAvatar.to_id avatar) (IPoll.to_id poll)

  let answered aid poll = 
    let! answer_opt = ohm $ MyUnique.get_if_exists (key aid poll) in
    return $ BatOption.is_some answer_opt

  module ByAnswer = Fmt.Make(struct
    type json t = (IPoll.t * int)
  end)

  module ByAvatar = CouchDB.DocView(struct
    module Key    = IAvatar
    module Value  = Fmt.Unit
    module Doc    = Answer
    module Design = Design
    let name = "by_avatar" 
    let map  = "if (doc.t == 'pans') emit(doc.w,null);"
  end)

  let _ = 
    let obliterate ansid = 
      let! ans = ohm_req_or (return ()) $ AnswerTable.get ansid in 
      let! ()  = ohm $ MyUnique.remove_atomic (key (ans # who) (ans # poll)) ansid in
      let! ()  = ohm $ AnswerTable.delete ansid in
      let! ()  = ohm $ refresh (ans # poll) in
      return ()
    in
    let on_obliterate_avatar (aid,_) = 
      let! list = ohm $ ByAvatar.doc aid in
      let! _    = ohm $ Run.list_map (#id |- obliterate) list in
      return ()
    in
    Sig.listen MAvatar.Signals.on_obliterate on_obliterate_avatar

  module ByAnswerView = CouchDB.MapView(struct
    module Key = ByAnswer
    module Value = IAvatar
    module Design = Design
    let name = "by_answer"
    let map  = "if (doc.t == 'pans') for (var k in doc.a) emit([doc.p,doc.a[k]],doc.w);" 
  end)
      
  let get_all ~count poll answer = 
    let key = (IPoll.decay poll,answer) in
    let! list = ohm $ ByAnswerView.query ~startkey:key ~endkey:key ~limit:count () in
    return $ List.map (#value) list

  let get avatar poll = 
    let! id = ohm_req_or (return []) $ MyUnique.get_if_exists (key avatar poll) in
    let! answer = ohm_req_or (return []) $ AnswerTable.get id in
    return (answer # answers)
	      
  let set avatar poll answers = 

    let obj = object
      method t       = `PollAnswer
      method who     = IAvatar.decay avatar
      method answers = answers
      method poll    = IPoll.decay poll
    end in

    let! id = ohm $ MyUnique.get (key avatar poll) in
    let! () = ohm $ AnswerTable.set id obj in
    let! () = ohm $ refresh poll in
    return ()

  module ByPollView = CouchDB.DocView(struct
    module Key    = IPoll
    module Value  = Fmt.Unit
    module Doc    = Answer
    module Design = Design
    let name = "by_poll"
    let map  = "if (doc.t == 'pans') emit(doc.p)"
  end)
	
  let delete_all_now poll = 

    let poll = IPoll.decay poll in

    let remove_answer answer = 
      let! () = ohm $ AnswerTable.delete (answer # id) in
      let! () = ohm $ MyUnique.remove (key (answer # doc # who) poll) in
      return ()
    in

    let! answers = ohm $ ByPollView.doc poll in
    let! _       = ohm $ Run.list_map remove_answer answers in
    return () 

end

let delete_now poll = 
  let! () = ohm $ Answer.delete_all_now poll in
  Tbl.delete (IPoll.decay poll)
