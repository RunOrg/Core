(* © 2012 MRunOrg *)

open Ohm
open Ohm.Universal

module Reason = Fmt.Make(struct
  module IOrder = IRunOrg.Order
  type json t = [ `Order of IOrder.t ]
end)

module PaypalConfig = struct
  module MainDB    = CouchDB.Convenience.Config(struct let db = O.db "paypal" end)
  module VersionDB = CouchDB.Convenience.Config(struct let db = O.db "paypal-v" end)
  module Id        = IPayment
  module Reason    = Reason
  let testing = MModel.Paypal.testing
end

module MyPaypal = OhmCouchPaypal.Make(PaypalConfig)

module Signals = MyPaypal.Signals

type t = MyPaypal.Payment.t

let get id = 
  let  id = IPayment.decay id in
  let! payment = ohm_req_or (return None) $ MyPaypal.get id in
  return (Some payment)

let reason p = p.MyPaypal.Payment.reason
let amount p = p.MyPaypal.Payment.amount
let status p = BatOption.map (fun status -> status # value) p.MyPaypal.Payment.status 
let error  p = p.MyPaypal.Payment.error

let start_transaction ~amount ~tax ~invoice ~returnurl ~cancelurl ~reason = 
  
  let id = IPayment.gen () in
  let returnurl = returnurl id in
  let cancelurl = cancelurl id in
  
  MyPaypal.setExpressCheckout
    ~id
    ~amount
    ~tax
    ~invoice
    ~returnurl
    ~cancelurl
    ~reason
    ~config:MModel.Paypal.config
    ~locale:`FR

let is_payable id = 

  let! payment = ohm_req_or (return `Failed) $ MyPaypal.get id in
  let  attempted = match status payment with None | (Some `None) -> false | _ -> true in
  let  success = OhmCouchPaypal.summary (status payment) <> `No in

  if error payment <> None then return `Failed else 
    if attempted then return (if success then `Paid payment else `Failed) else 
      let! success = ohm $ 
	MyPaypal.getExpressCheckoutDetails id ~config:MModel.Paypal.config
      in
      if success then 
	return $ `Payable (payment, IPayment.Assert.exec id)
      else  
	return `Failed
    
	
let finish_transaction id = 
  let id = IPayment.decay id in
  MyPaypal.doExpressCheckoutPayment id ~config:MModel.Paypal.config
