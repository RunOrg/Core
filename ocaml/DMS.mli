(* © 2013 RunOrg *)

module IRepository : sig
  include Ohm.Id.PHANTOM
  module Assert : sig
    val admin : 'any id -> [`Admin] id
    val view  : 'any id -> [`View]  id 
  end
end

module Url : sig
  val home : (IWhite.key,string list) Ohm.Action.endpoint 
end
