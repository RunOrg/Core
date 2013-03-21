(* © 2013 RunOrg *)

open Common
open DMS_common
module Build = DMS_build

(* Champs génériques du "Dublin core", préfixe "DC" --------------------------------------------------------- *)

let dateCreated = field "DC.Date->Created"
  (adlib "DC_Date_Created" "Date de création") 
  `Date 

let dateReceived = field "DC.Date->Received"
  (adlib "DC_Date_Received" "Date de réception") 
  `Date

let description = field "DC.Description"
  (adlib "DC_Description" "Description")
  `TextLong

let subject = field "DC.Subject"
  (adlib "DC_Subject" "Sujet et mots-clés")
  (`AtomMany Atom.topic)

let creator = field "DC.Creator"
  (adlib "DC_Creator" "Créateur ou origine")
  `TextShort

(* Les modèles de champs génériques ------------------------------------------------------------------------- *)

let () = fieldset "Default" [
  description ;
  subject ;
  creator ;
  dateCreated ;
  dateReceived ;
]

(* Champs spécifiques à la FFBAD, préfixe "FFBAD" ----------------------------------------------------------- *)

module FFBAD = struct

  let codeOrigine = field "FFBAD.CodeOrigine"
    (adlib "FFBAD_CodeOrigine" "Code Origine")
    (`PickOne [ "75", adlib "FFBAD_CodeOrigine_75" "Paris" ;
		"78", adlib "FFBAD_CodeOrigine_78" "Yvelines" ])
    
  let () = fieldset "FFBAD" [
    description ;
    subject ;
    creator ;
    dateCreated ;
    dateReceived ;
    codeOrigine ;
  ]

end
