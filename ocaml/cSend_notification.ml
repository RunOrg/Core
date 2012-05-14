(* © 2012 RunOrg *)

open Ohm
open Ohm.Util
open BatPervasives
open Ohm.Universal

module MyMembership   = CSend_myMembership
module NetworkInvite  = CSend_networkInvite
module NetworkConnect = CSend_networkConnect
module CommentItem    = CSend_commentItem
module LikeItem       = CSend_likeItem 
module PublishItem    = CSend_publishItem 
module JoinPending    = CSend_joinPending
module JoinEntity     = CSend_joinEntity
module ChatRequest    = CSend_chatRequest

let _ = 
  let! notification = Sig.listen MNotification.Signals.on_send in

  let cuid = IUser.Assert.is_safe (notification # who) in
  let uid = IUser.Deduce.is_self cuid in

  let url = 
    (UrlCore.notify ()) # build 
      (IUser.Deduce.self_can_login uid) 
      (notification # id)
  in
  
  begin match notification # what with 
    | `networkInvite  i -> NetworkInvite.send  uid url notification i
    | `networkConnect i -> NetworkConnect.send uid url notification i
    | `myMembership   m -> MyMembership.send   uid url notification m
    | `likeItem       i -> LikeItem.send       uid url notification i
    | `commentItem    c -> CommentItem.send    uid url notification c
    | `welcome        w -> return ()
    | `joinEntity     j -> JoinEntity.send     uid url notification j
    | `joinPending    j -> JoinPending.send    uid url notification j 
    | `publishItem    p -> PublishItem.send    uid url notification p
    | `chatReq        r -> ChatRequest.send    uid url notification r 
  end

  |> Run.map ignore
