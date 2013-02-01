(* © 2013 RunOrg *)

open Common

let desc = 
  field ~label:(adlib "EntityFieldDesc" "Description")
    ~required:true
    ~mean:`Description
    `Textarea "desc" 
    
let picture = 
  field ~label:(adlib "EntityFieldPicture" "Image")
    ~mean:`Picture
    `Picture "pic" 
    
let date = 
  field ~label:(adlib "EntityFieldDate" "Date")
    ~mean:`Date
    `Date "date" 
    
let location = 
  field ~label:(adlib "EntityFieldAddress" "Adresse")
    ~help:(adlib "EntityFieldAddressExplain" "Inscrivez l'adresse complète : un lien automatique est fait vers Google Maps")
    ~mean:`Location
    `LongText "address" 
    
