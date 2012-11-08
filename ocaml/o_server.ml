(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let domain default = function
  | None -> default 
  | Some wid -> try ConfigWhite.domain wid with Not_found -> default

let server default owid = object
  val domain = domain default owid
  method protocol () = `HTTP
  method domain () = domain
  method port () = 80
  method cookie_domain () = Some ("." ^ domain)
  method matches protocol domain' port = 
    if protocol <> `HTTP then None else
      if domain = domain' then Some () else None 
end

let core default = object
  method protocol _ = `HTTP
  method domain = domain default 
  method port _ = 80
  method cookie_domain owid = Some ("." ^ domain default owid)
  method matches protocol domain port = 
    if protocol <> `HTTP then None else 
      if domain = default then Some None else
	match ConfigWhite.white domain with 
	  | Some wid -> Some (Some wid)
	  | None -> None     
end

let secure default = object
  method protocol _ = `HTTPS
  method domain = domain default
  method port _ = 443
  method cookie_domain owid = Some ("." ^ domain default owid)
  method matches protocol domain port = 
    if protocol <> `HTTPS then None else
      if domain = default then Some None else
	match ConfigWhite.white domain with 
	  | Some wid -> Some (Some wid)
	  | None -> None
end 

let client default = object 
  method protocol _ = `HTTP
  method domain (prefix,owid) = prefix ^ "." ^ domain default owid
  method port _ = 80
  method cookie_domain (_,owid) = Some ("." ^ domain default owid) 
  method matches protocol domain port = 
    if protocol <> `HTTP then None else
      match ConfigWhite.slice_domain domain with 
	| None, _ -> None
	| Some key, owid -> Some (key,owid)
end
