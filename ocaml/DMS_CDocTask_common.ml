(* © 2013 RunOrg *)

module IRepository = DMS_IRepository
module MRepository = DMS_MRepository
module IDocument   = DMS_IDocument
module MDocument   = DMS_MDocument
module MDocMeta    = DMS_MDocMeta
module IDocTask    = DMS_IDocTask
module MDocTask    = DMS_MDocTask
module Url         = DMS_Url

open Ohm
open Ohm.Universal

let parent key rid doc = object
  method title = return (MDocument.Get.name doc) 
  method url   = Action.url Url.file key [ IRepository.to_string rid ; 
					   IDocument.to_string (MDocument.Get.id doc) ]
end
