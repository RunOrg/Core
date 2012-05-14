(* © 2012 RunOrg *)

let box ~(ctx : 'a CContext.full) ~group = 
  let gid = MGroup.Get.id group in
  CDirectory.entity_box ~gid ~ctx
