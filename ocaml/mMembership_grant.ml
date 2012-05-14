(* © 2012 MRunOrg *) 

open Ohm
open Ohm.Universal

module Versioned = MMembership_versioned

module MembershipGrantView = CouchDB.ReduceView(struct

  module Design = Versioned.Design
  module Key = IAvatar
  module Value = Fmt.Make(struct
    type json t = [ `Admin "a" | `Token "t" ]
  end)
  module Reduced = Value

  let name = "grant"
  let map  = "if (doc.r.grant) emit(doc.c.who,doc.r.grant)"
  let reduce = "
    var r = null;
    for (var i = 0; i < values.length; ++i) 
      if (values[i] == 'a') r = 'a';
      else if (values[i] == 't' && r != 'a') r = 't';
    return r;"

  let group = true
  let level = None

end)

let get avatar = 
  MembershipGrantView.reduce (IAvatar.decay avatar) 

let react ?from avatar = 
  let! status = ohm $ get avatar in
  match status with 
    | None        -> MAvatar.downgrade_to_contact ?from (IAvatar.Assert.bot avatar)
    | Some `Admin -> MAvatar.upgrade_to_admin ?from (IAvatar.Assert.bot avatar)
    | Some `Token -> MAvatar.change_to_member ?from (IAvatar.Assert.bot avatar)

