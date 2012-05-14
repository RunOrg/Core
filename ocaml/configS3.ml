(* © 2012 RunOrg *)

module Account = struct
  let id  = "AKIAJROGGR2WVFBNMBLA"
  let key = "Dz9Au/7i2aqRjdNdUy9iyyQOuQvDKQI7TlV37YWQ" 
end

include OhmAmazon.S3(Account)
