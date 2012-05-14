(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open Ohm.Universal
open BatPervasives
open O

(* Creating and editing a buy order -------------------------------------------------------- *)

module BuyEdit = struct

  module Fields = FClient.Buy.Fields
  module Form   = FClient.Buy.Form

  let action ~ctx ~order ~client ~cid ~oid = 
    O.Box.reaction "edit-order" begin fun self bctx data response ->
      
      let i18n = ctx # i18n in 
      
      (* Extract the form data *)
      
      let main     = ref None
      and name     = ref "" 
      and address  = ref "" 
      and memory   = ref None in
      
      let form = Form.readpost (bctx # post)
        |> Form.optional  `Main     IRunOrg.Offer.fmt main 
        |> Form.optional  `Memory   IRunOrg.Offer.fmt memory
        |> Form.mandatory `Name     Fmt.String.fmt     name    (i18n,`label "field.required")
        |> Form.mandatory `Address  Fmt.String.fmt     address (i18n,`label "field.required")
      in          
      
      let main = !main |> BatOption.bind 
	  (fun id -> let id = IRunOrg.Offer.Assert.main id in 
		     try Some (id, List.assoc id MRunOrg.Offer.main) with _ -> None)
      in
      
      let memory = !memory |> BatOption.bind
	  (fun id -> let id = IRunOrg.Offer.Assert.memory id in
		     try Some (id, List.assoc id MRunOrg.Offer.memory) with _ -> None)
      in
      
      let form_fail = return (Action.json (Form.response form) response) in
      
      let! _ = true_or form_fail (Form.is_valid form) in
      
    (* Create or update the order *)
      
      let fail = CCore.js_fail_message (ctx # i18n) "changes.error" response in
      
      let! _ = true_or fail (
	match order with 
	  | None -> true
	  | Some order -> order.MRunOrg.Order.Data.status = `Preparing
      ) in
      
      let! (main_id, main) = req_or fail main in
      
      let kind =
	`Upgrade (object
	  method days = main # days
	  method seat = (object
	    method daily  = main # daily 
	    method seats  = main # seats
	    method memory = main # memory
	    method offer  = IRunOrg.Offer.decay main_id
	  end)
	  method memory = match memory with None -> None | Some (memory_id, memory) -> Some (object
	    method daily = memory # daily
	    method memory = memory # memory
	    method offer  = IRunOrg.Offer.decay memory_id
	  end)
	end)
      in
      
      let! self = ohm $ ctx # self in
      
      let rebate = MRunOrg.Client.rebate client in 
      let time   = Unix.gettimeofday () in
      let name = !name in
      let address = !address in
      
      let! () = ohm (
	(if order = None then MRunOrg.Order.prepare ~client:cid else MRunOrg.Order.update)
	  oid ~user:self ~kind ~rebate ~time ~name ~address
      ) in
      
    (* Redirect to order page *)
      
      let order_url = UrlAssoOptions.order ctx oid in
      
      return (Action.javascript (Js.redirect order_url) response)
	
    end
end
      
let buy_box ~ctx = 
    
  let the_box ~ctx ~init ~cancel_url ~order ~oid ~client ~cid = 
    let! save = BuyEdit.action ~ctx ~order ~oid ~client ~cid in
    O.Box.leaf
      begin fun bctx url ->
	return (
	  VAssoClient.Buy.render (object
	    method cancel_url = cancel_url
	    method form_url   = bctx # reaction_url save
	    method init       = init
	  end) (ctx # i18n) 
	)
      end
  in
  
  O.Box.decide
    begin fun _ (((url,_),oid),proof) ->
      
      let root = 
	let (++) = Box.Seg.(++) in
	let base = Box.Seg.root ++ CSegs.home_pages ++ CSegs.client_tabs `Client in
	UrlR.build (ctx # instance) base (((),`Client),`Client)
      in
      
      let fail = 
	return (O.Box.error (fun _ _ -> return
	  (JsCode.seq [ Js.redirect root ;
			Js.message (I18n.get (ctx # i18n) (`label "view.error")) ] 
	  )))
      in
      
      let! oid   = req_or fail oid in
      let! proof = req_or fail proof in
      
	let iid = IInstance.decay (IIsIn.instance (ctx # myself)) in
	
	let! edit_oid = req_or fail (
	  IRunOrg.Order.Deduce.from_edit_token
	    (IIsIn.user (ctx # myself)) iid oid proof
	) in
	
	let! (cid, client) = ohm_req_or fail (MRunOrg.Client.by_instance iid) in
	
	let! order_opt = ohm (MRunOrg.Order.get oid) in
	
	let! profile = ohm_req_or fail (MInstance.Profile.get iid) in

	let init, cancel_url, fail = 
	  match order_opt with
	      
	    | Some order ->
	      begin	    
	      (* An order was found *)
		let cancel = UrlAssoOptions.order ctx edit_oid in
		
		if order.MRunOrg.Order.Data.status <> `Preparing then 
		  FClient.Buy.Form.empty, cancel, true
		    
		else match order.MRunOrg.Order.Data.kind with 
		  | `Renew   _ -> FClient.Buy.Form.empty, cancel, true
		  | `Upgrade u -> 
		    FClient.Buy.Form.initialize begin function
		      | `Name    -> Json_type.String order.MRunOrg.Order.Data.name
		      | `Address -> Json_type.String order.MRunOrg.Order.Data.address
		      | `Main    -> IRunOrg.Offer.to_json (u # seat # offer)
		      | `Memory  -> match u # memory with
			  | Some m ->  IRunOrg.Offer.to_json (m # offer)
			  | None   -> Json_type.String "none"			
		    end, cancel, false
	      end 
		
		
	    | None -> 
	      
	      FClient.Buy.Form.initialize begin function
		| `Name    -> Json_type.String (ctx # instance # name)
		| `Address -> Json_type.Build.optional Json_type.Build.string
		  (profile # address) 
		| `Main    -> Json_type.Null
		| `Memory  -> Json_type.Null
	      end, root, false
		
	in
	
	if fail then 
	  return (O.Box.error (fun _ _ -> return (Js.redirect cancel_url)))
	else 
	  return (the_box ~ctx ~init ~cancel_url ~order:order_opt ~oid:edit_oid ~client ~cid) 
	    
      end         
    |> O.Box.parse CSegs.string
    |> O.Box.parse CSegs.order_id
	

(* Viewing an order ------------------------------------------------------------------------ *)

let order_box ~ctx = 

  let the_box ~ctx ~order ~oid = 
    O.Box.leaf
      begin fun input url ->

	let i18n = ctx # i18n in

	let time, tax, total, rebate, kind, status = 
	  MRunOrg.Order.Data.( 
	    order.time, order.tax, order.total, order.rebate, order.kind, order.status
	  )
	in

	let date = MRunOrg.Client.day_of_time time in

	let lines = [

	  begin 
	    match kind with `Renew _ -> None | `Upgrade u ->
	      try let order = List.assoc
		    (IRunOrg.Offer.Assert.main (u # seat # offer)) MRunOrg.Offer.main
		  in		  
		  let name  = I18n.translate i18n (order # label) in
		  Some (object
		    method item = `text 
		      (View.write_to_string (I18n.get_param i18n "order-line.item.main"
					       [ View.str name ]))
		    method detail = `text
		      (View.write_to_string
			 (I18n.get_param i18n "order-line.detail.main"
			    [ View.str (string_of_int (u # seat # seats)) ;
			      View.str (MRunOrg.Offer.print_memory (u # seat # memory)) ;
			      View.str (MRunOrg.Client.string_of_day (u # days + date)) ]))

		    method price = let (n,d) = u # seat # daily in 
				   u # days * n / d
		  end)
	      with Not_found -> None
	  end ;

	  begin 
	    match kind with `Renew _ -> None | `Upgrade u ->
	      match u # memory with None -> None | Some m ->
		try let order = List.assoc
		      (IRunOrg.Offer.Assert.memory (m # offer)) MRunOrg.Offer.memory 
		    in		  
		    let name  = I18n.translate i18n (order # label) in
		    Some (object
		      method item = `text 
			(View.write_to_string (I18n.get_param i18n "order-line.item.memory"
						 [ View.str name ]))
		      method detail = `text
			(View.write_to_string
			   (I18n.get_param i18n "order-line.detail.memory"
			      [ View.str (MRunOrg.Offer.print_memory (m # memory)) ;
				View.str (MRunOrg.Client.string_of_day (u # days + date)) ]))

		      method price = let (n,d) = m # daily in 
				     u # days * n / d
		    end)
		with Not_found -> None
	  end ;

	  begin 
	    match kind with `Upgrade _ -> None | `Renew r ->
	      try let order = List.assoc 
		    (IRunOrg.Offer.Assert.main (r # seat # offer)) MRunOrg.Offer.main 
		  in		  
		  let name  = I18n.translate i18n (order # label) in
		  Some (object
		    method item = `text 
		      (View.write_to_string (I18n.get_param i18n "order-line.item.main"
					       [ View.str name ]))
		    method detail = `text
		      (View.write_to_string
			 (I18n.get_param i18n "order-line.detail.main"
			    [ View.str (string_of_int (r # seat # seats)) ;
			      View.str (MRunOrg.Offer.print_memory (r # seat # memory)) ;
			      View.str (MRunOrg.Client.string_of_day (r # days + r # start)) 
			    ]))

		    method price = let (n,d) = r # seat # daily in 
				   r # days * n / d
		  end)
	      with Not_found -> None
	  end ;

	  begin 
	    match kind with `Upgrade _ -> None | `Renew r ->
	      match r # memory with None -> None | Some m ->
		try let order = List.assoc 
		      (IRunOrg.Offer.Assert.memory (m # offer)) MRunOrg.Offer.memory 
		    in		  
		    let name  = I18n.translate i18n (order # label) in
		    Some (object
		      method item = `text 
			(View.write_to_string (I18n.get_param i18n "order-line.item.memory"
						 [ View.str name ]))
		      method detail = `text
			(View.write_to_string
			   (I18n.get_param i18n "order-line.detail.memory"
			      [ View.str (MRunOrg.Offer.print_memory (m # memory)) ;
				View.str (MRunOrg.Client.string_of_day (r # days + r # start))
			      ]))

		      method price = let (n,d) = m # daily in 
				     r # days * n / d
		    end)
		with Not_found -> None
	  end ;
		    
	  begin 
	    if rebate > 0 then Some (object
	      method item   = `label "order-line.item.rebate"
	      method detail = `label "order-line.detail.rebate"
	      method price  = - rebate
	    end) else None
	  end ;
	  
	]

	in	
	
	let buttons = 
	  let cancel = UrlAssoOptions.client (ctx # instance) in 
	  let edit   = UrlAssoOptions.edit_order ctx oid in
	  let pay    = UrlPayment.order_start # build ctx oid in

	  if status = `Preparing then 
	    match kind with 
	      | `Upgrade _ -> VAssoClient.OrderEdit.render (object
		method cancel = cancel
		method edit   = edit
		method pay    = pay
	      end)
	      | `Renew _ -> VAssoClient.OrderPay.render (object
		method cancel = cancel
		method pay    = pay
	      end)
	  else
	    VAssoClient.OrderBack.render cancel
	in
	
	return (
	  VAssoClient.Order.render (object
	    method ht      = total - tax
	    method ttc     = total
	    method tva     = tax
	    method lines   = BatList.filter_map identity lines
	    method buttons = buttons
	    method time    = order.MRunOrg.Order.Data.time
	    method id      = IRunOrg.Order.decay oid
	    method name    = order.MRunOrg.Order.Data.name
	    method address = order.MRunOrg.Order.Data.address
	  end) (ctx # i18n) 
	)
      end
  in

  O.Box.decide
    begin fun _ (((url,_),oid),proof) ->

      let root = UrlAssoOptions.client (ctx # instance) in 

      let fail = 
	return (O.Box.error (fun _ _ -> return
	  (JsCode.seq [ Js.redirect root ; Js.message (I18n.get (ctx # i18n) (`label "view.error")) ] 
	)))
      in

      let! oid   = req_or fail oid in
      let! proof = req_or fail proof in

      let iid = IInstance.decay (IIsIn.instance (ctx # myself)) in

      let! edit_oid = req_or fail (
	IRunOrg.Order.Deduce.from_edit_token
	  (IIsIn.user (ctx # myself)) iid oid proof
      ) in

      let! order = ohm_req_or fail (MRunOrg.Order.get oid) in
      
      return (the_box ~ctx ~order ~oid:edit_oid ) 

    end         
  |> O.Box.parse CSegs.string
  |> O.Box.parse CSegs.order_id

(* Preparing a renewal order --------------------------------------------------------------- *)

module PrepareRenewal = struct

  let action ~ctx ~client ~cid = 
    O.Box.reaction "prepare-renewal" begin fun self bctx data response ->

      let main = client.MRunOrg.Client.Data.offer |> BatOption.bind 
	  (fun id -> let id = IRunOrg.Offer.Assert.main id in 
		     try Some (id, List.assoc id MRunOrg.Offer.main) with _ -> None)
      in
      
      let memory = client.MRunOrg.Client.Data.mem_offer |> BatOption.bind
	  (fun id -> let id = IRunOrg.Offer.Assert.memory id in
		     try Some (id, List.assoc id MRunOrg.Offer.memory) with _ -> None)
      in
      
      let fail = CCore.js_fail_message (ctx # i18n) "changes.error" response in
      
      let! main_id, main = req_or fail main in   
      
      let today = MRunOrg.Client.today () in
      
      let kind =
	`Renew (object
	  method days = main # days
	  method start = max client.MRunOrg.Client.Data.last_day today
	  method seat = (object
	    method daily  = main # daily 
	    method seats  = main # seats
	    method memory = main # memory
	    method offer  = IRunOrg.Offer.decay main_id
	  end)
	  method memory = match memory with 
	    | None -> None
	    | Some (memory_id, memory) -> Some (object
	      method daily = memory # daily
	      method memory = memory # memory
	      method offer  = IRunOrg.Offer.decay memory_id
	    end)
	end)
      in
      
      let! self = ohm $ ctx # self in
      
      let rebate = 0 in
      let oid    = IRunOrg.Order.Assert.edit (IRunOrg.Order.gen ()) in
      let time   = Unix.gettimeofday () in
      
      let address = client.MRunOrg.Client.Data.address in
      let name    = client.MRunOrg.Client.Data.name in 
      
      let! () = ohm $ MRunOrg.Order.prepare
	~client:cid oid ~user:self ~kind ~rebate ~time ~address ~name
      in
      
      (* Redirect to order page *)
      
      let order_url = UrlAssoOptions.order ctx oid in
      
      return (Action.javascript (Js.redirect order_url) response)
	
    end
end

(* Box that describes the current status of the client ------------------------------------- *)

let client_box ~(ctx:[`IsAdmin] CContext.full) = 

  let the_box ~client ~cid = 

    let! renew = PrepareRenewal.action ~ctx ~client ~cid in

    O.Box.leaf
      begin fun bctx (url,_) ->	

	let light = ctx # instance # light in 

	let offer = 
	  match client.MRunOrg.Client.Data.offer with None -> None | Some oid ->
	    let oid = IRunOrg.Offer.Assert.main oid in 
	    try let offer = List.assoc oid MRunOrg.Offer.main in
		Some (offer # label) 
	    with _ -> None
	in

	let mem_offer = 
	  if offer = None then None else 
	    match client.MRunOrg.Client.Data.mem_offer with None -> None | Some oid ->
	      let oid = IRunOrg.Offer.Assert.memory oid in 
	      try let offer = List.assoc oid MRunOrg.Offer.memory in
		  Some (offer # label) 
	      with _ -> None
	in

	let iid = IInstance.Deduce.can_see_usage (IIsIn.instance (ctx # myself)) in
	let! (used,_) = ohm (MFile.Usage.instance iid) in
	
	let used_memory = int_of_float used in

	let! used_seats = ohm (MAvatar.usage iid) in

	let buy_url oid = 

	  let proof = 
	    IRunOrg.Order.Deduce.make_edit_token 
	      (IIsIn.user (ctx # myself))
	      (IInstance.decay (IIsIn.instance (ctx # myself)))
	      oid
	  in

	  let oid = IRunOrg.Order.decay oid in 

	  let (++) = Box.Seg.(++) in
	  let segs = (bctx # segments) ++ CSegs.order_id ++ CSegs.string in

	  UrlR.build (ctx # instance) segs (((url,`Buy),Some oid),Some proof)

	in

	let actions = match offer with 

	  | None ->
	    let new_order = IRunOrg.Order.gen () |> IRunOrg.Order.Assert.edit in
	    [
	      `label "client.action.buy" , VIcon.cart_go , 
	      Js.redirect (buy_url new_order) 
	    ]

	  | Some _ ->
	    let upgrade = IRunOrg.Order.gen () |> IRunOrg.Order.Assert.edit in
	    [
	      `label "client.action.upgrade" , VIcon.cart_go,
	      Js.redirect (buy_url upgrade) ;

	      `label "client.action.renew" , VIcon.date_go,
	      Js.runFromServer (bctx # reaction_url renew)
	    ]

	in

	let! orders = ohm (MRunOrg.Order.by_client cid) in

	let orders =
	  (* Reverse the list to get reverse chronological order *)
	  List.rev_map (fun (oid,order) ->

	    let offer = 

	      let oid = match order.MRunOrg.Order.Data.kind with 
		| `Renew   r -> r # seat # offer
		| `Upgrade u -> u # seat # offer
	      in

	      let oid = IRunOrg.Offer.Assert.main oid in 

	      try let offer = List.assoc oid MRunOrg.Offer.main in
		  offer # label
	      with _ -> `label "offer.trial"

	    in
	    
	    let mem_offer = 
	    
	      let mem_order = match order.MRunOrg.Order.Data.kind with 
		| `Renew   r -> r # memory
		| `Upgrade u -> u # memory
	      in

	      match mem_order with None -> None | Some order ->
		
		let oid = IRunOrg.Offer.Assert.memory order # offer in 

		try let offer = List.assoc oid MRunOrg.Offer.memory in
		    Some (offer # label) 
		with _ -> None

	    in
	    
	    let order_url = UrlAssoOptions.order ctx oid in

	    (object
	      method offer     = offer
	      method mem_offer = mem_offer
	      method time      = order.MRunOrg.Order.Data.time
	      method id        = IRunOrg.Order.decay oid
	      method url       = order_url
	      method price     = order.MRunOrg.Order.Data.total
	     end)

	  ) orders
	in

	let current =
	  if light then `free (object
	    method used_seats  = used_seats
	    method used_memory = used_memory
	    method memory      = client.MRunOrg.Client.Data.memory	      
	  end) else `paying (object
	    method offer       = BatOption.default (`label "offer.trial") offer
	    method mem_offer   = mem_offer
	    method used_seats  = used_seats
	    method seats       = client.MRunOrg.Client.Data.seats
	    method used_memory = used_memory
	    method memory      = client.MRunOrg.Client.Data.memory
	    method date        = MRunOrg.Client.(string_of_day client.Data.last_day) 
	  end)
	in

	return (
	  VAssoClient.Client.render (object
	    method current     = current 
	    method actions     = (fun i18n -> VActionList.list ~list:(CActionList.make actions) ~i18n)
	    method orders      = match orders with [] -> None | l -> Some l
	  end) (ctx # i18n) 
	)
      end 
  in

  O.Box.decide 
    begin fun _ _ ->
      let fail = return (O.Box.error (fun _ _ -> return Js.panic)) in

      let! (cid,client) = ohm_req_or fail
	(MRunOrg.Client.by_instance (IIsIn.instance (ctx # myself))) 
      in

      return (the_box ~client ~cid) 
    end

(* The box containing the tabs ------------------------------------------------------------- *)

let home_box ~ctx = 
  let tabs ~ctx = 
    let list = 
      [
	CTabs.fixed `Client (`label "asso-options.tab.client") (lazy (client_box ~ctx)) ;
	CTabs.hidden (function
	  | `Buy   -> return (Some ((`label "asso-options.tab.buy"),   buy_box   ~ctx))
	  | `Order -> return (Some ((`label "asso-options.tab.order"), order_box ~ctx))
	  | _      -> return  None
	)
      ]
    in

    CTabs.box
      ~list
      ~url:(UrlR.build (ctx # instance))
      ~i18n:(ctx # i18n)
      ~default:`Client
      ~seg:CSegs.client_tabs
  in
  let content = "c" in
  O.Box.node
    begin fun input _ -> 
      return [content, tabs ~ctx],
      return 
	(VAssoClient.Home.render (input # name,content) (ctx # i18n))
    end
      
