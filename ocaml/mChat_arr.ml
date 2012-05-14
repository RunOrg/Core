(* © 2012 RunOrg *)

include OhmArr.Connect(struct
  let host = "runorg.com"
  let port = 6547
  let salt = "42"
end)
