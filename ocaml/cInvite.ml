(* © 2012 RunOrg *)

open Ohm
open Ohm.Universal
open BatPervasives

let box wrapper = 
  O.Box.fill begin

    wrapper begin
      Asset_Invite_ByEmail.render (object
	method url = Json.Null
      end)
    end

  end
