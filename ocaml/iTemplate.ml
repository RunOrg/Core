(* © 2012 RunOrg *)

open Ohm

include PreConfig_TemplateId

type 'rel id = t

let decay id = id

let forum   = `ForumPublic

module Assert = struct 
end
  
module Deduce = struct
end

module Event = struct

  include PreConfig_TemplateId.Events
    
  type 'rel id = t
      
  let decay id = id    
    
  module Assert = struct 
  end
    
  module Deduce = struct
  end
    
end

module Group = struct

  include PreConfig_TemplateId.Groups
    
  type 'rel id = t

  let admin   = `Admin
  let members = `GroupSimple
      
  let decay id = id    
    
  module Assert = struct 
  end
    
  module Deduce = struct
  end
    
end

