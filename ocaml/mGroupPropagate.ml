(* © 2012 RunOrg *)

open Ohm
open BatPervasives
open Ohm.Universal

module Diff = Fmt.Make(struct

  type json t = <
    action : [`add|`remove] ;
    src : string ;
    dest : string 
  >

end)

let names _ = []

let apply upgrade namer diff = 
  let! src = ohm $ MPreConfigNamer.avatarSet (diff # src) namer in
  let src = IAvatarSet.Assert.bot src in 

  let! dest = ohm $ MPreConfigNamer.avatarSet (diff # dest) namer in
  let dest = IAvatarSet.Assert.bot dest in

  upgrade ~src ~dest (diff # action)

module Entity = struct

  module Diff = Fmt.Make(struct
            
    type json t = <
      action : [`add|`remove] ;
      dest : string 
    >
	
  end)
    
  let names _ = []
    
  let apply_diffs list namer diffs = 

    let! diffs = ohm begin 
      Run.list_map begin fun diff -> 
	let! dest = ohm $ MPreConfigNamer.group (diff # dest) namer in
	return (diff # action, dest)
      end diffs
    end in 

    return (
      List.fold_left begin fun acc (action, id) ->
	match action with 
	  | `add    -> id :: acc
	  | `remove -> BatList.remove acc id
      end list diffs |> BatList.unique
    )

end
