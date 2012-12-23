(* © 2012 RunOrg *)

type 'role t = {
  aid : IAvatar.t ;
  uid : [`Old] ICurrentUser.id ;
  iid : 'role IInstance.id ;
  role : [`Contact|`Admin|`Token]
}

let contact t = {
  aid  = t.aid ;
  uid  = t.uid ;
  role = t.role ;
  iid  = IInstance.Assert.is_contact t.iid
}

let member t = match t.role with 
  | `Contact -> None
  | `Token | `Admin -> Some {
    aid  = t.aid ;
    uid  = t.uid ;
    role = t.role ;
    iid  = IInstance.Assert.is_token t.iid
  }

let admin t = match t.role with 
  | `Contact | `Token -> None
  | `Admin -> Some {
    aid  = t.aid ;
    uid  = t.uid ;
    role = t.role ;
    iid  = IInstance.Assert.is_admin t.iid
  }

let avatar t = 
  IAvatar.Assert.is_self t.aid

let instance t = 
  t.iid

let user t = 
  t.uid

module Make = struct

  let contact ~role ~aid ~iid ~uid = {
    aid  = IAvatar.decay aid ;
    uid  ;
    iid  = IInstance.Assert.is_contact iid ;
    role ;
  }

end
