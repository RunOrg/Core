(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open CMe_common

module Parents = CMe_account_parents

let () = define UrlMe.Account.def_picture begin fun cuid -> 

  O.Box.fill begin

    Asset_Admin_Page.render (object
      method parents = [ Parents.home ; Parents.admin ] 
      method here  = Parents.picture # title
      method body  = return $ Html.str "" 
    end)

  end
end
