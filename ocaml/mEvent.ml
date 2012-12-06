(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

type 'relation t = unit

module Vision = Fmt.Make(struct
  type json t = [ `Website "w" | `Normal "n" | `Secret "s" ]
end) 

module Can = struct
  let view  _ = assert false
  let admin _ = assert false
end

module Data = struct
 
  type 'relation t = unit

  let address _ = assert false
  let page    _ = assert false

end

module Get = struct

  let id       _ = assert false
  let draft    _ = assert false
  let vision   _ = assert false
  let name     _ = assert false
  let picture  _ = assert false
  let date     _ = assert false
  let group    _ = assert false
  let iid      _ = assert false
  let template _ = assert false
  let admins   _ = assert false

  let public   _ = assert false
  let status   _ = assert false
  let data     _ = assert false

end

let create ~self ~name ?pic ?(vision=`Normal) ~iid tid = 
  assert false

module Set = struct

  let picture t self fid = 
    assert false    

  let admins t self aids = 
    assert false

  let info t self ~draft ~name ~page ~address ~vision = 
    assert false

end

module All = struct

  let future ?access iid = 
    assert false

  let drafts access iid = 
    assert false

  let past ?access ?start ~count iid = 
    assert false

end

let get ?access id = 
  assert false

let delete t self = 
  assert false
