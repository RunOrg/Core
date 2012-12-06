(* © 2012 RunOrg *)

open Ohm

include PreConfig_TemplateId

type 'rel id = t

let decay id = id

let admin   = `Admin
let members = `GroupSimple
let forum   = `ForumPublic

module Assert = struct 
end
  
module Deduce = struct
end
