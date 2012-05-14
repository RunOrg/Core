(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

open MVote_common
module Data = MVote_data
type t = Data.Question.t

let create ~multiple ~question ~answers = object
  method multiple = multiple
  method answers  = answers
  method question = question
end

let get t = t.data.Vote.question

