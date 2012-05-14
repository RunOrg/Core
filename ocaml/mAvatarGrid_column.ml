(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

module Eval = MAvatarGrid_eval

module T = struct
  module View = MGroupColumn.View
  type json t = {
    eval  : Eval.t ;
    label : [ `label of string | `text of string ] ;
    show  : bool ;
    view  : View.t
  }
end

include T 
include Ohm.Fmt.Extend(T)

type column = t = {
  eval  : Eval.t ;
  label : [ `label of string | `text of string ] ;
  show  : bool ;
  view  : MGroupColumn.View.t
}

let key_of_column column = column.eval

let make_eval self iid namer = function
  | `profile what -> return begin match what with 
      | `firstname -> `Profile (iid,`Firstname)
      | `lastname  -> `Profile (iid,`Lastname)
      | `email     -> `Profile (iid,`Email)
      | `birthdate -> `Profile (iid,`Birthdate)
      | `city      -> `Profile (iid,`City)
      | `address   -> `Profile (iid,`Address)
      | `zipcode   -> `Profile (iid,`Zipcode)
      | `country   -> `Profile (iid,`Country)
      | `phone     -> `Profile (iid,`Phone)
      | `cellphone -> `Profile (iid,`Cellphone)
      | `gender    -> `Profile (iid,`Gender)
  end
  | `self what -> return begin match what with 
      | `state   -> `Group (self, `Status)
      | `date    -> `Group (self, `Date)
      | `field f -> `Group (self, `Field f)
  end
  | `named (n,what) -> 
    let! gid = ohm $ MPreConfigNamer.group n namer in 
    return begin match what with 
      | `state   -> `Group (gid, `Status)
      | `date    -> `Group (gid, `Date)
      | `field f -> `Group (gid, `Field f)
    end

let apply self iid namer t = function 

  | `Refresh -> return t

  | `Remove e -> 
    let! key = ohm $ make_eval self iid namer e in
    return $ ListAssoc.unset key t
      
  | `Add col -> 
    let! eval = ohm $ make_eval self iid namer (col # eval) in
    let value = {
      show  = col # show ;
      eval  ;
      view  = col # view ;
      label = `label (col # label)
    } in

    let key = key_of_column value in 

    let! after = ohm begin 
      match col # after with 
	| None      -> return None
	| Some eval -> 
	  let! after = ohm $ make_eval self iid namer eval in
	  return $ Some after
    end in

    let t = ListAssoc.replace key value t in 
    let t = ListAssoc.move ?after key t in
    
    return t

let columns_to_assoc cols = 
  List.map (fun col -> key_of_column col, col) cols

let assoc_to_columns assoc = 
  List.map snd assoc

let apply_diffs t self iid namer (diffs : MGroupColumn.Diff.t list) = 
  let assoc = columns_to_assoc t in 

  let rec aux assoc = function
    | [] -> return assoc
    | diff :: diffs ->
      let! assoc = ohm $ apply self iid namer assoc diff in
      aux assoc diffs
  in

  let! assoc = ohm $ aux assoc diffs in

  return $ assoc_to_columns assoc

