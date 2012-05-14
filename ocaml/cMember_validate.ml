(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open O
open Ohm.Universal
  
let reaction ~ctx ~group = 
  O.Box.reaction "member-validate" begin fun self input url response ->
    
    let i18n = ctx # i18n in 
    let fail = CCore.js_fail_message i18n "changes.error" response in 
    
    let! joins = req_or fail (CMember_common.grab_selected input) in	     
    let! self  = ohm (ctx # self) in
    
    let! _     = ohm (CJoin.Validate.validate_many ~self ~joins ~group) in
    
    let code = 
      JsCode.seq [ 
	Js.message (I18n.get i18n (`label "changes.soon")) ;
	JsBase.boxRefresh 2000.0
      ]	  
    in
    
    return (Action.javascript code response)
  end
    
