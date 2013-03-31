(* © 2012 RunOrg *)
open Common

(* ========================================================================== *)
let healthAntecedents = profileForm "HealthAntecedents" 
  ~name:"Antécédents"
  [ 
     join ~name:"medicaux"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Medicaux" "Médicaux")
         `LongText ;
     join ~name:"chirurgicaux"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Chirurgicaux" "Chirurgicaux")
         `LongText ;
     join ~name:"obstetriques"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Obstetriques" "Obstétriques")
         `LongText ;
     join ~name:"familiaux"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Familiaux" "Familiaux")
         `LongText ;
    join ~name:"risks"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Risks" "Facteurs de risques")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthAntecedentsRisksHTA" "HTA" ;
			adlib "ProfileFormValuesSectionHealthAntecedentsRisksDiabete" "Diabète" ;
			adlib "ProfileFormValuesSectionHealthAntecedentsRisksObesite" "Obésité" ;
			adlib "ProfileFormValuesSectionHealthAntecedentsRisksHypercholesterolemie" "Hypercholestérolémie" ;
			adlib "ProfileFormValuesSectionHealthAntecedentsRisksTabagisme" "Tabagisme" ] ) ;
  ]	

(* ========================================================================== *)
let healthExamen = profileForm "HealthExamen" 
  ~name:"Examen"
  [ 
     join ~name:"date"
         ~label:(adlib "ProfileForm_HealthExamen_Field_date" "Date")
         `Date ;
     join ~name:"type"
         ~label:(adlib "ProfileForm_HealthExamen_Field_type" "Type d'examen")
         `Textarea ;
     join ~name:"soignant"
         ~label:(adlib "ProfileForm_HealthExamen_Field_soignant" "Nom du soignant")
         `Textarea ;
    join ~name:"paresthesies"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Paresthesies" "Paresthésies")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenParesthesiesBrulure" "Brulure" ;
			adlib "ProfileFormValuesHealthExamenParesthesiesFourmillement" "Fourmillement" ;
			adlib "ProfileFormValuesHealthExamenParesthesiesAutre" "Autre" ] ) ;
    join ~name:"crampes"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Crampes" "Crampes")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenCrampesEffort" "A l'effort" ;
			adlib "ProfileFormValuesHealthExamenCrampesRepos" "Au repos" ] ) ;
  ]

(* ========================================================================== *)
let sectionSportEtudesAcademic = profileForm "SectionSportEtudesAcademic" 
  ~name:"Scolaire"
  [ 
     join ~name:"noteteacher"
         ~label:(adlib "ProfileForm_SectionSportEtude_Field_NoteTeacher" "Remarques responsable suivi scolaire")
         `Textarea ;
     join ~name:"notemanagement"
         ~label:(adlib "ProfileForm_SectionSportEtude_Field_NoteManagement" "Remarques encadrement")
         `Textarea ;
  ]		 

(* ========================================================================== *)
let sectionSportEtudesBilan = profileForm "SectionSportEtudesBilan" 
  ~name:"Bilan"
  [
    join ~name:"period"
         ~label:(adlib "ProfileForm_SectionSportEtudesBilan_Field_Period" "Période")
         `LongText ;
    join ~name:"trainings"
         ~label:(adlib "ProfileForm_SectionSportEtudesBilan_Field_Trainings" "Entraînements")
         `Textarea ;
    join ~name:"tournaments"
         ~label:(adlib "ProfileForm_SectionSportEtudesBilan_Field_Tournaments" "Compétitions")
         `Textarea ;
    join ~name:"academic"
         ~label:(adlib "ProfileForm_SectionSportEtudesBilan_Field_Academic" "Scolaire")
         `Textarea ;
    join ~name:"medical"
         ~label:(adlib "ProfileForm_SectionSportEtudesBilan_Field_Medical" "Médical")
         `Textarea ;
    join ~name:"general"
         ~label:(adlib "ProfileForm_SectionSportEtudesBilan_Field_General" "Général")
         `Textarea ;
  ]

(* ========================================================================== *)
let sectionSportEtudesCompetition_Judo = profileForm "SectionSportEtudesCompetition_Judo" 
  ~name:"Compétition"
  [
    join ~name:"name"
         ~label:(adlib "ProfileForm_SectionSportEtudesCompetition_Field_Name" "Nom")
         `Textarea ;
    join ~name:"date"
         ~label:(adlib "ProfileForm_SectionSportEtudesCompetition_Field_Date" "Date")
         `Date ;
    join ~name:"type"
         ~label:(adlib "ProfileForm_SectionSportEtudesCompetition_Field_Type" "Type")
		 (`PickOne [
			adlib "ProfileFormValuesSectionSportEtudesCompetitionTounament" "Tournois" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetitionChampionshim" "Championnat" ] ) ;
    join ~name:"competition"
         ~label:(adlib "ProfileForm_SectionSportEtudesCompetition_Field_Competition" "Compétition")
		 (`PickOne [
			adlib "ProfileFormValuesSectionSportEtudesCompetitionIndividual" "Individuel" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetitionTeam" "Par équipe" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetitionScholar" "Scolaire" ] ) ;
    join ~name:"level"
         ~label:(adlib "ProfileForm_SectionSportEtudesCompetition_Field_Level" "Niveau")
		 (`PickOne [
			adlib "ProfileFormValuesSectionSportEtudesCompetitionNational" "National" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetitionRegional" "Régional" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetitionDepartmental" "Départemental" ] ) ;
    join ~name:"performance"
         ~label:(adlib "ProfileForm_SectionSportEtudesCompetition_Field_Performance" "Performance")
		 (`PickOne [
			adlib "ProfileFormValuesSectionSportEtudesCompetition1" "1er" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetition2" "2nd" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetition3" "3ème" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetition5" "5ème" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetition7" "7ème" ;
			adlib "ProfileFormValuesSectionSportEtudesCompetitionNC" "NC" ] ) ;
    join ~name:"notetrainer"
         ~label:(adlib "ProfileForm_SectionSportEtudes_Field_NoteTrainer" "Remarques entraîneur")
         `Textarea ;
  ]		 

(* ========================================================================== *)
let sectionSportEtudesMedical = profileForm "SectionSportEtudesMedical" 
  ~name:"Médical"
  [
        join ~name:"date"
         ~label:(adlib "ProfileForm_SectionSportEtudesMedical_Field_Date" "Date")
         `Date ;
	join ~name:"injury"
         ~label:(adlib "ProfileForm_SectionSportEtudesMedical_Field_Injury" "Type de blessure")
         `LongText ;
	join ~name:"dayoff"
         ~label:(adlib "ProfileForm_SectionSportEtudesMedical_Field_DayOff" "NB jours d'arrêt")
         `Textarea ;
    join ~name:"note"
         ~label:(adlib "ProfileForm_SectionSportEtudes_Field_Note" "Remarques")
         `LongText ;
  ]
   
(* ========================================================================== *)
let sectionSportEtudesTrainings = profileForm "SectionSportEtudesTrainings" 
  ~name:"Entraînements"
  [ 
     join ~name:"notetrainer"
         ~label:(adlib "ProfileForm_SectionSportEtudes_Field_NoteTrainer" "Remarques entraîneur")
         `Textarea ;
  ]		 
 
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
 

