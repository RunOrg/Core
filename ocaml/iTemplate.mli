(* © 2013 RunOrg *)

type 'rel id = PreConfig_TemplateId.t

include Ohm.Fmt.FMT with type t = [`Unknown] id
  
val to_string : 'any id -> string
val of_string : string -> t option

val decay : 'any id -> t

val forum : t 

module Assert : sig
end
  
module Deduce : sig
end

module Event : sig

  type 'rel id = PreConfig_TemplateId.Events.t
      
  include Ohm.Fmt.FMT with type t = [`Unknown] id
    
  val to_string : 'any id -> string
  val of_string : string -> t option
    
  val decay : 'any id -> t

  module Assert : sig
  end
    
  module Deduce : sig
  end
    
end

module Group : sig

  type 'rel id = PreConfig_TemplateId.Groups.t
  
  include Ohm.Fmt.FMT with type t = [`Unknown] id

  val admin : t
  val members : t       
    
  val to_string : 'any id -> string
  val of_string : string -> t option
    
  val decay : 'any id -> t

  module Assert : sig
  end
    
  module Deduce : sig
  end
    
end
