(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module ListItem = struct
  module T = struct
    type json t = {
      id         : IAvatar.t ;
      img        : string ;
      name       : string ;
      status_css : string ;
      status     : string
    }
  end
  include T
  include Fmt.Extend(T)
end

let search ~ctx ~directory = 
  O.Box.reaction "search" begin fun _ bctx _ res ->
    
    let respond list = return $ O.Action.json 
      ["list", Json_type.Build.list ListItem.to_json list] res 
    in   
    
    let extract (id,_,details) = 

      let status  = ctx # status (match details # status with Some x -> x | None -> `Contact) in
      let name    = CName.get (ctx # i18n) details in 
      
      let! img    = ohm (ctx # picture_small (details # picture)) in
      
      return ListItem.({
	id ;
	name ;
	img ;
	status_css = VStatus.css_class status ;
	status     = I18n.translate (ctx # i18n) (VStatus.label status)
      })
    in

    let term = BatOption.default "" (Fmt.String.of_json_safe (bctx # json)) in

    let count = 12 in 
    let! list = ohm (MAvatar.search directory term count) in      
    let! result = ohm (Run.list_map extract list) in

    respond result
	  
  end 

let add_one ctx mode from entity aid = 

  let! details = ohm $ MAvatar.details aid in 

  let! () = true_or (return ()) 
    (details # ins = Some (MEntity.Get.instance entity))
  in

  let  gid    = MEntity.Get.group entity in 
  let! group  = ohm_req_or (return ()) (MGroup.try_get ctx gid) in
  let! group  = ohm_req_or (return ()) (MGroup.Can.write group) in

  let  actions = match mode with 
    | `invite -> [ `Invite ; `Accept true ] 
    | `add    -> [ `Accept true ; `Default true ]
  in

  let! _ = ohm $ MMembership.admin ~from (MGroup.Get.id group) aid actions in 
  
  return ()

module TaskArgs = struct
  module T = struct
    type json t = {
      list   : IAvatar.t list ;
      eid    : IEntity.t ;
      from   : IAvatar.t ;
      mode   : [ `add | `invite ] ;
      total  : int 
    }
  end
  include T
  include Fmt.Extend(T)
end

let add_many = 
  let task = Task.register "add-members-search" TaskArgs.fmt begin fun args _ -> 

    (* Do not spend more than one second on this iteration *)
    let max_time = Unix.gettimeofday () +. 1.0 in 

    let continue list = 
      let data = TaskArgs.({ args with list = list }) in    
      let len  = List.length list in 
      if len = 0 then Task.Finished data else Task.Partial (data, len, data.TaskArgs.total) 
    in

    (* Acting as the avatar to add everyone *)
    
    let  self = IAvatar.Assert.is_self args.TaskArgs.from in 
    let! isin = ohm_req_or (return Task.Failed) $ MAvatar.identify_avatar self in 
    let  ctx  = CContext.make isin in 

    let  eid    = args.TaskArgs.eid in 
    let! entity = ohm_req_or (return Task.Failed) $ MEntity.try_get ctx eid in 
    let! entity = ohm_req_or (return Task.Failed) $ MEntity.Can.view entity in  


    let rec work = function 
      | []                                        -> return $ continue []
      | list when Unix.gettimeofday () > max_time -> return $ continue list  
      | avatar :: list ->
	
	let! () = ohm $ add_one ctx args.TaskArgs.mode self entity avatar in
	
	work list 

    in
    
    work args.TaskArgs.list             
  end in

  fun mode self eid list -> 

    let data = TaskArgs.({
      list  ; 
      from  = IAvatar.decay self ;
      eid   = IEntity.decay eid ;
      mode  = mode ;
      total = List.length list 
    }) in

    let! _ = ohm $ MModel.Task.call task data in
    return ()
      
	

module AddArgs = Fmt.Make(struct
  type json t = <
    mode : [ `add | `invite ] ;
    list : IAvatar.t list
  >
end)


let add ~ctx entity = 
  O.Box.reaction "add" begin fun _ bctx _ res ->

    let panic = return $ O.Action.javascript Js.panic res in 

    (* Extract arguments *)
    
    let! args = req_or panic $ AddArgs.of_json_safe (bctx # json) in

    let list  = BatList.sort_unique compare (args # list) in 
    let total = List.length list in 

    let eid = IEntity.decay $ MEntity.Get.id entity in 

    let! self = ohm $ ctx # self in 

    (* Perform addition *)

    let! () = ohm begin
      match list with 
	| []    -> return ()
	| [aid] -> add_one ctx (args # mode) self entity aid
	| list  -> add_many (args # mode) self eid list
    end in 

    (* Redirect after a delay *)

    let time = 
      if total = 0 then 0.0 else
	2000.0 +. 500.0 *. (float_of_int (min 10 total)) 
    in

    let url = UrlR.build (ctx # instance)
      O.Box.Seg.(UrlEntity.segments ++ UrlSegs.entity_tabs)
      ((((),`Entity),Some eid),`Admin_People)
    in
    
    return $ O.Action.javascript (JsCode.seq [
      Js.message (I18n.get (ctx # i18n) (`label "changes.soon")) ;
      JsBase.delay time (JsBase.boxLoad url) 
    ]) res

  end

let box ~ctx ~directory entity = 
  let! search = search ~ctx ~directory in
  let! add    = add    ~ctx entity in 
  O.Box.leaf begin fun bctx _ ->
    let search_url = bctx # reaction_url search in 
    let add_url    = bctx # reaction_url add in
    return $ VAdd.Search.render (object
      method search_url = search_url
      method add_url    = add_url
    end) (ctx # i18n)
  end
