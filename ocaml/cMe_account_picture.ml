(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

let () = define UrlMe.Account.def_picture begin fun cuid -> 

  O.Box.fill begin

    let html = Asset_MeAccount_Picture.render (object
      method url = Json.Null 
      method upload = "" 
      method pics = "" 
      method back = Parents.home # url 
    end) in

    Asset_Admin_Page.render (object
      method parents = [ Parents.home ; Parents.admin ] 
      method here  = Parents.picture # title
      method body  = html
    end)

  end
end
