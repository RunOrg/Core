(* © 2013 RunOrg *)

open Common
open Task_common
module Build = Task_build

module Context = struct
  let dms = "DMS"
end

module States = struct

  let short = states "short" 
    [ "new",      "Nouveau",  false ;
      "invalid",  "Invalide", true ; 
      "finished", "Fini",     true ]
    
  let long = states "long" 
    [ "new",        "Nouveau",  false ;
      "accepted",   "Accepté",  false ;
      "inProgress", "En cours", false ;
      "invalid",    "Invalide", true ;
      "finished",   "Fini",     true ]

end

module Field = struct

  let modeEnvoi = field "DocSendMode" "Mode d'envoi"
    (`PickOne [ "email", adlib "Task_Field_DocSendMode_Email" "Par e-mail" ;
		"mail",  adlib "Task_Field_DocSendMode_Mail"  "Courrier" ;
		"pmail", adlib "Task_Field_DocSendMode_Pmail" "Courrier prioritaire" ])

  let dateExpedition = field "DocSendDate"
    (adlib "Task_Field_DocSendDate" "Date d'envoi")
    `Date

end

module Process = struct

  let () = process "DMS_ReadDocument" Context.dms States.short 
    "Prendre connaissance de ce document"
    [
    ]

  let () = process "DMS_Respond" Context.dms States.short 
    "Répondre à ce document"
    [ 
      Field.modeEnvoi ;
      Field.dateExpedition ;
    ]

end
