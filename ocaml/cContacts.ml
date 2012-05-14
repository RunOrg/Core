(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

(* The home page itself ------------------------------------------------------------------- *)

let count = 10

module Pager = CPaging.More(struct
  module Key = Fmt.Make(struct
    module Float = Fmt.Float
    type json t = Float.t * IAvatar.t
  end) 
  type data = IAvatar.t * float
end)
      
class ['a,'b] source iid ctx = object (self)

  val iid = iid
  val ctx = ( ctx : 'a CContext.full )

  method list start = 
    MAvatar.Pending.get_latest_confirmed ?start ~count iid

  method render view more (list : Pager.data list) = 
    let! list = ohm (CAvatar.extract_map (ctx # i18n) ctx fst list) in
    
    let list = List.map (fun ((aid,time),details) -> 
      (object
	method time    = time
	method url     = details # url
	method picture = details # picture
	method name    = details # name
	method status  = details # status
       end)  
    ) list in

    return (view ~more ~list (ctx # i18n))

  method more ~(bctx:'b) ~more ~list = 
    self # render 
      (fun ~more ~list -> 
	VContact.More.render (object
	  method more = more
	  method list = list
	end)
      ) more list

  method page ~(bctx:'b) ~more ~list = 
    self # render  
      (fun ~more ~list -> 
	VContact.Page.render (object
	  method more = more
	  method list = list
	  method access = Some (`Page `Admin)
	end)
      ) more list

end

(* The home page itself ------------------------------------------------------------------- *)

let home_box ~iid ~ctx = 
  Pager.box (new source iid ctx)
