(* © 2012 IRunOrg *)

type 'rel id = {
  role     : [`Admin|`Token|`Contact|`Nobody] ;
  avatar   : [`IsSelf] IAvatar.id option ;
  instance : 'rel IInstance.id ;
  user     : [`Unsafe] ICurrentUser.id 
}
    
let cast f c = {
  role     = c.role ;
  avatar   = c.avatar ;
  instance = f c.instance ;
  user     = c.user
}
  
let user     t = t.user
let instance t = t.instance
let role     t = t.role
let avatar   t = t.avatar
  
module Assert = struct
    
  let make ~role ~id ~ins ~light ~trial ~usr = {
    role     = begin match role with 
      | `Contact -> `Contact
      | `Nobody  -> `Nobody
      | `Admin   -> `Admin
      | `Token   -> if light && not trial then `Admin else `Token 
    end ;
    avatar   = id ;
    instance = ins ;
    user     = usr 
  }
    
end
  
module Deduce = struct

  let is_anyone  id = cast IInstance.decay id
    
  let is_admin   id = 
    match role id with 
      | `Admin -> Some (cast IInstance.Assert.is_admin id) 
      | _ -> None

  let is_token   id = 
    match role id with 
      | `Admin | `Token -> Some (cast IInstance.Assert.is_token id) 
      | _ -> None

  let is_contact id = 
    match role id with 
      | `Admin | `Token | `Contact -> Some (cast IInstance.Assert.is_contact id)
      | _ -> None
        
  let create_can_view  ins = ins
    
  let see_contacts         = instance
end

