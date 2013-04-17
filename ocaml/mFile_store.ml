(* © 2013 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

include Fmt.Make(struct
  type json t = (IFile.Storage.t * Json.t) 
end)

type store = t

module type STORAGE = sig
  module Handle   : Ohm.Fmt.FMT
  module UpHandle : Ohm.Fmt.FMT
  include Ohm.Fmt.FMT   
  val id : IFile.Storage.t
  val owner : t -> [ `User of IUser.t | `Instance of IInstance.t ]
  val prepare : 
       maxsize:float
    -> t 
    -> (#O.ctx, < 
         handle : UpHandle.t ; 
         form   : string -> <
           post   : (string * string) list ; 
	   key    : string ; 
           url    : string 
         >
       > option) Ohm.Run.t
  val find : UpHandle.t -> t -> (#O.ctx,Handle.t option) Ohm.Run.t
  val url : Handle.t -> t -> (#O.ctx,string option) Ohm.Run.t
  val upload : 
       public:bool 
    -> filename:string 
    -> string
    -> t 
    -> (#O.ctx, Handle.t option) Ohm.Run.t
  val download : Handle.t -> t -> (#O.ctx,< 
    filename : string ; 
    local    : string ;
    size     : float  ;
  > option) Ohm.Run.t
  val delete : Handle.t -> t -> (#O.ctx,unit) Ohm.Run.t
end

type ('ctx) provider = <
  owner : [ `User of IUser.t | `Instance of IInstance.t ] ;
  find : Ohm.Json.t -> ('ctx,Ohm.Json.t option) Ohm.Run.t ;
  url  : Ohm.Json.t -> ('ctx,string option) Ohm.Run.t ;
  prepare : maxsize:float -> ('ctx, <
    handle : Ohm.Json.t ;
    form   : string -> <
      post   : (string * string) list ;
      key    : string ;
      url    : string
    >
  > option) Ohm.Run.t ;
  upload : public:bool -> filename:string -> string -> ('ctx, Ohm.Json.t option) Ohm.Run.t ;
  download : Ohm.Json.t -> ('ctx,<
    filename : string ;
    local    : string ;
    size     : float ;
  > option) Ohm.Run.t ;
  delete : Ohm.Json.t -> ('ctx,unit) Ohm.Run.t
> 

let providers = Hashtbl.create 2

let provider (id,json) = 
  try let p = Hashtbl.find providers id json in 
      match p with None -> None | Some p -> 
	Some (object
	  method owner = p # owner
	  method find handle = O.decay (p # find handle)
	  method url handle = O.decay (p # url handle)
	  method prepare ~maxsize = O.decay (p # prepare ~maxsize)
	  method upload ~public ~filename path = O.decay (p # upload ~public ~filename path)
	  method download handle = O.decay (p # download handle)
	  method delete handle = O.decay (p # delete handle) 
	end)
  with Not_found -> None

module RegisterStorage = functor(S:STORAGE) -> struct

  type t = S.t
  let make t = (S.id, S.to_json t) 

  let () = Hashtbl.add providers S.id begin fun json ->     
    match S.of_json_safe json with None -> None | Some t -> Some (object
      method owner = S.owner t
      method find json = 
	let! uphandle = req_or (return None) (S.UpHandle.of_json_safe json) in
	let! handle   = ohm_req_or (return None) (S.find uphandle t) in
	return (Some (S.Handle.to_json handle)) 
      method url json = 
	let! handle = req_or (return None) (S.Handle.of_json_safe json) in
	S.url handle t
      method prepare ~maxsize = 
	let! prep   = ohm_req_or (return None) (S.prepare ~maxsize t) in
	return (Some (object
	  method handle = S.UpHandle.to_json (prep # handle)
	  method form confirm = prep # form confirm
	end))
      method upload ~public ~filename path =
	let! handle = ohm_req_or (return None) (S.upload ~public ~filename path t) in
	return (Some (S.Handle.to_json handle))
      method download json = 
	let! handle = req_or (return None) (S.Handle.of_json_safe json) in
	S.download handle t
      method delete json = 
	let! handle = req_or (return ()) (S.Handle.of_json_safe json) in
	S.delete handle t	
    end)
  end

end
