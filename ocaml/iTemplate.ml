(* © 2012 RunOrg *)

open Ohm

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

