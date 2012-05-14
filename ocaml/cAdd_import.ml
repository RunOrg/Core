(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module ImportArgs = struct
  module T = struct
    type json t = {
      list   : (string * string * string) list ;
      eid    : IEntity.t ;
      from   : IAvatar.t ;
      total  : int 
    }
  end
  include T
  include Fmt.Extend(T)
end

let import_task = Task.register "full-member-import" ImportArgs.fmt begin fun args _ ->

  (* Do not spend more than one second on this iteration *)
  let max_time = Unix.gettimeofday () +. 1.0 in 

  let continue list = 
    let data = ImportArgs.({ args with list = list }) in    
    let len = List.length list in 
    if len = 0 then Task.Finished data else Task.Partial (data, len, data.ImportArgs.total) 
  in

  (* Acting as the avatar to add everyone *)

  let  self = IAvatar.Assert.is_self args.ImportArgs.from in 
  let! isin = ohm_req_or (return Task.Failed) $ MAvatar.identify_avatar self in 
  let  ctx  = CContext.make isin in 
  let  inst = IIsIn.instance isin in 

  let rec work = function 
    | []                                        -> return $ continue []
    | list when Unix.gettimeofday () > max_time -> return $ continue list  
    | (email, firstname, lastname) :: list ->
      
      let! avatar = ohm $ CHelper.create_avatar 
	~firstname
	~lastname
	~email:(Some email)
	inst
      in 

      let actions = [ `Accept true ; `Default true ] in

      let! added = ohm_req_or (return Task.Failed) $ CHelper.add_avatar_to_entity
	~force:true ~actions ctx avatar args.ImportArgs.eid
      in
    
      work list 

  in

  work args.ImportArgs.list             

end

module Input = Fmt.Make(struct
  type json t = (string * string * string) list
end)

let reaction ~ctx (entity:[`Admin] MEntity.t) = 
  O.Box.reaction "import" begin fun _ bctx _ res ->

    let panic = return (O.Action.javascript (JsCode.seq [
      Js.panic ;
      Js.message (I18n.get (ctx # i18n) (`label "view.error")) 
    ]) res) in 

    let! list = req_or panic $ Input.of_json_safe (bctx # json) in

    let  eid  = IEntity.decay $ MEntity.Get.id entity in
    let! self = ohm $ ctx # self in
    let  from = IAvatar.decay self in 

    let total = List.length list in

    let args = ImportArgs.({ from ; eid ; list ; total }) in

    let! _ = ohm $ MModel.Task.call import_task args in

    let time = 2000.0 +. 500.0 *. (float_of_int (min 10 total)) in

    let url = UrlR.build (ctx # instance)
      O.Box.Seg.(UrlEntity.segments ++ UrlSegs.entity_tabs)
      ((((),`Entity),Some eid),`Admin_People)
    in
    
    return $ O.Action.javascript (JsCode.seq [
      Js.message (I18n.get (ctx # i18n) (`label "changes.soon")) ;
      JsBase.delay time (JsBase.boxLoad url) 
    ]) res

  end

let box ~ctx entity = 
  let! reaction = reaction ~ctx entity in 
  O.Box.leaf begin fun bctx _ -> 
    return $ VAdd.Import.render (object
      method url = bctx # reaction_url reaction
    end) (ctx # i18n) 
  end
