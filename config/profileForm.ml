(* © 2012 RunOrg *)
open Common

(* ========================================================================== *)
let simple = profileForm "Simple" 
  ~name:"Commentaire / Remarque"
  ~comment:true []

(* ========================================================================== *)
let test = profileForm "Test" 
  ~name:"Test"
  [
    join ~name:"checkbox" 
         ~label:(adlib "ProfileForm_Test_Field_Checkbox" "Case à cocher")
         `Checkbox ;
    join ~name:"textarea"
         ~label:(adlib "ProfileForm_Test_Field_Textarea" "Zone texte")
         `Textarea ;
    join ~name:"longtext"
         ~label:(adlib "ProfileForm_Test_Field_LongText" "Champ texte")
         `LongText ;
    join ~name:"date"
         ~label:(adlib "ProfileForm_Text_Field_Date" "Date")
         `Date ;
    join ~name:"pickone"
         ~label:(adlib "ProfileForm_Text_Field_PickOne" "Choix simple")
         (`PickOne Adlib.ColumnName.([ firstname ; lastname ; email ; gender ])) ;
    join ~name:"pickmany"
         ~label:(adlib "ProfileForm_Text_Field_PickMany" "Choix multiple")
         (`PickMany Adlib.ColumnName.([ firstname ; lastname ; email ; gender ])) ;        		
  ]
 

