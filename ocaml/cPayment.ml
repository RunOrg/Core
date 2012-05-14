(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal

let () = CClient.User.register CClient.is_contact UrlPayment.order_start begin fun ctx request response ->  

  let fail = CCore.js_fail_message (ctx # i18n) "view.error" response in
  
  let! oid   = req_or fail (request # args 0) in
  let! proof = req_or fail (request # args 1) in

  let! oid = req_or fail
    (IRunOrg.Order.Deduce.from_edit_token 
       (IIsIn.user (ctx # myself))
       (IInstance.decay (IIsIn.instance (ctx # myself)))
       (IRunOrg.Order.of_string oid) 
       proof) 
  in

  let! order = ohm_req_or fail (MRunOrg.Order.get oid) in

  let amount, tax = MRunOrg.Order.Data.(
    order.total , order.tax 
  ) in

  if amount > 0 then begin 
    
    (* Non-zero payment, redirect to paypal *)

    let cancelurl = fun _ -> UrlAssoOptions.order ctx oid  in
    let returnurl = UrlPayment.ok # build (ctx # instance) in
    let reason = `Order (IRunOrg.Order.decay oid) in
    
    let! url = ohm_req_or fail (
      MPayment.start_transaction ~amount ~tax
	~invoice:(IRunOrg.Order.to_string oid) 
	~returnurl ~cancelurl ~reason
    ) in
    
    return (Action.javascript (Js.redirect url) response) 

  end else begin 

    (* Zero payment, simply validate *)

    let! self = ohm $ ctx # self in

    let! () = ohm $ MRunOrg.Order.accept_free oid ~user:self in

    let url = UrlAssoOptions.client (ctx # instance) in

    return (Action.javascript (Js.redirect url) response)

  end
    
end

let () = CClient.User.register CClient.is_contact UrlPayment.ok begin fun ctx request response ->  

  let fail = 
    let title = return (I18n.get (ctx # i18n) (`label "view.error")) in
    let body = 
      return (VPayment.Error.render (object
	method asso = ctx # instance # name
	method back = UrlR.home # build (ctx # instance) 
      end) (ctx # i18n))
    in
    CCore.render ~title ~body response
  in

  let! pid = req_or fail (request # args 0) in
  let pid = IPayment.of_string pid in 

  let! payable = ohm (MPayment.is_payable pid) in

  match payable with 
    | `Failed -> fail
    | `Paid payment   -> begin

      let title = return (I18n.get (ctx # i18n) (`label "pay.thanks.title")) in
      let body = return (
	VPayment.Thanks.render (object
	  method asso = ctx # instance # name
	  method continue = match MPayment.reason payment with 
	    | `Order o -> UrlAssoOptions.client (ctx # instance)
	  method amount  = MPayment.amount payment
	end) (ctx # i18n)
      ) in
      
      CCore.render ~title ~body response

    end

    | `Payable (payment, pid) -> begin
      
      let title = return (I18n.get (ctx # i18n) (`label "pay.confirm.title")) in
      let body  = return (
	VPayment.Accept.render (object
	  method asso    = ctx # instance # name
	  method cancel  = match MPayment.reason payment with 
	    | `Order o -> UrlAssoOptions.client (ctx # instance) 
	  method amount  = MPayment.amount payment
	  method confirm = UrlPayment.exec # build (ctx # instance) (IIsIn.user (ctx # myself)) pid
	end) (ctx # i18n)
      ) in
      
      CCore.render ~title ~body response 

    end

end

let () = CClient.User.register_ajax CClient.is_contact UrlPayment.exec begin 
  fun ctx request response ->  
    
    let redirect id = return
      (Action.javascript (Js.redirect (UrlPayment.ok # build (ctx # instance) id)) response)
    in
    
    let fail = redirect (IPayment.gen ()) in
    
    let! pid = req_or fail (request # args 0) in
    let pid = IPayment.of_string pid in 
    
    let! proof = req_or fail (request # args 1) in
    
    let! pid = req_or fail (IPayment.Deduce.from_exec_token
				    (IIsIn.user (ctx # myself)) pid proof)
    in
    
    let! _ = ohm_req_or fail (MPayment.finish_transaction pid) in
    
    redirect (IPayment.decay pid)
      
end
