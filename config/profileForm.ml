(* © 2012 RunOrg *)
open Common

(* ========================================================================== *)
let healthAntecedents = profileForm "HealthAntecedents" 
  ~name:"Antécédents"
  [ 
     join ~name:"medicaux"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Medicaux" "Médicaux")
         `Textarea ;
     join ~name:"chirurgicaux"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Chirurgicaux" "Chirurgicaux")
         `Textarea ;
     join ~name:"obstetriques"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Obstetriques" "Obstétriques")
         `Textarea ;
     join ~name:"familiaux"
         ~label:(adlib "ProfileForm_HealthAntecedents_Field_Familiaux" "Familiaux")
         `Textarea ;
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
let healthBilanComplications = profileForm "HealthBilanComplications" 
  ~name:"Bilan de complications"
  [ 
    join ~name:"complicationCerebrale"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationCerebrale" "Complication cérébrale")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCerebraleAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCerebraleAIT" "AIT" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCerebraleAVCHemorragique" "AVC hémorragique" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCerebraleAVCIschemique" "AVC ischemique" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCerebraleDemence" "Démence" ] ) ;
    join ~name:"dopplerArteresCarotides"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_DopplerArteresCarotides" "Doppler des Artères carotides (date/médecin)")
         `LongText ;
    join ~name:"tDM"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_TDM" "TDM (date/médecin)")
         `LongText ;
    join ~name:"complicationOculaire"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationOculaire" "Complication cérébrale")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOculaireAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOculaireRPD" "RPD" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOculaireMaculopathie" "Maculopathie" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOculaireRPHT" "RPHT" ] ) ;
    join ~name:"fondOeil"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_FondOeil" "Fond d'oeil (date/médecin)")
         `LongText ;
    join ~name:"complicationCardiaque"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationCardiaque" "Complication cardiaque")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCardiaqueAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCardiaqueAngor" "Angor" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCardiaqueIDM" "IDM" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCardiaqueStent" "Stent" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCardiaquePontage" "Pontage" ] ) ;
    join ~name:"eCG"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ECG" "ECG (date/médecin)")
         `LongText ;
    join ~name:"echographie"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_Echographie" "Echographie (date/médecin)")
         `LongText ;
    join ~name:"epreuveEffort"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_EpreuveEffort" "Epreuve d'effort (date/médecin)")
         `LongText ;
    join ~name:"scintigraphieMyocardique"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ScintigraphieMyocardique" "Scintigraphie myocardique (date/médecin)")
         `LongText ;
    join ~name:"coronarographie"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_Coronarographie" "Coronarographie (date/médecin)")
         `LongText ;
    join ~name:"complicationRespiratoire"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationRespiratoire" "Complication respiratoire")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationRespiratoireAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationRespiratoireSdRestrictif" "Sd restrictif" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationRespiratoireSdApneeSommei" "Sd apnée du sommei" ] ) ;
    join ~name:"complicationNeurovegetative"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationNeurovegetative" "Complication neurovégétative")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurovegetativeAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurovegetativeConstipation" "Constipation" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurovegetativeTachycardie" "Tachycardie" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurovegetativeHypersudation" "Hypersudation" ] ) ;
    join ~name:"complicationUrinaire"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationUrinaire" "Complication urinaire")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationUrinaireAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationUrinairenInfection" "Infection urinaire" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationUrinaireRetention" "Rétention urinaire" ] ) ;
    join ~name:"echographieVesicale"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_EchographieVesicale" "Echographie vesicale (date/médecin)")
         `LongText ;
    join ~name:"eCBU"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ECBU" "ECBU (date/médecin)")
         `LongText ;
    join ~name:"complicationRenal"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationRenal" "Complication renal")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationRenalAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationRenalNephrpathie" "Nephrpathie" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationRenalInsuffisanceRenale" "Insuffisance renale" ] ) ;
    join ~name:"microalbuminurie"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_Microalbuminurie" "Microalbuminurie (date/médecin)")
         `LongText ;
    join ~name:"proteinurie"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_Proteinurie" "Proteinurie (date/médecin)")
         `LongText ;
    join ~name:"clearanceCreatininurie"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ClearanceCreatininurie" "clearance de la créatininurie (date/médecin)")
         `LongText ;
    join ~name:"complicationSexuelle"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationSexuelle" "Complication sexuelle")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationSexuelleAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationSexuelleInfection" "Infection" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationSexuelleSecheresseVaginale" "Secheresse vaginale" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationSexuellePerteLibido" "Perte de libido" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationSexuelleTroubleErection" "Trouble de l'érection" ] ) ;
    join ~name:"prelevementVaginalGland"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_PrelevementVaginalGland" "Prélèvement vaginal/gland  (date/médecin)")
         `LongText ;
    join ~name:"dopplerPenien"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_DopplerPenien" "Doppler penien (date/médecin)")
         `LongText ;
    join ~name:"complicationNeurologique"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationNeurologique" "Complication neurologique")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurologiqueAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurologiqueNeuropathieSensitiveMIFSG1" "Neuropathie sensitive des MIFS Grade 1" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurologiqueNeuropathieSensitiveMIFSG2" "Neuropathie sensitive des MIFS Grade 2" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationNeurologiqueNeuropathieSensitiveMIFSG3" "Neuropathie sensitive des MIFS Grade 3" ] ) ;
    join ~name:"electromyogramme"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_Electromyogramme" "Electromyogramme (date/médecin)")
         `LongText ;
    join ~name:"complicationOsteoarticulaire"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationOsteoarticulaire" "Complication ostéoarticulaire")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOsteoarticulaireAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOsteoarticulaireOsteite" "Osteite" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOsteoarticulaireFracture" "Fracture" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationOsteoarticulaireArthrose" "Arthrose" ] ) ;
    join ~name:"radio"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_Radio" "Radio (date/médecin)")
         `LongText ;
    join ~name:"complicationCuntanee"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationCuntanee" "Complication cuntanée")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCuntaneeAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCuntaneePlaie" "Plaie" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCuntaneeDermite" "Dermite" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationCuntaneeMycose" "Mycose" ] ) ;
    join ~name:"prelevementCutanee"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_PrelevementCutanee" "Prelevement cutanee (date/médecin)")
         `LongText ;
    join ~name:"complicationArterielleMIFS"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_ComplicationArterielleMIFS" "Complication arterielle des membres inferieurs")
		 (`PickMany [
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationArterielleMIFSAbsence" "Absence" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationArterielleMIFSArteriosclerose" "Arteriosclerose" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationArterielleMIFSPlaques" "Plaques" ;
			adlib "ProfileFormValuesSectionHealthBilanComplicationsComplicationArterielleMIFSStenoses" "Stenoses" ] ) ;
    join ~name:"dopplerArteresMIFS"
         ~label:(adlib "ProfileForm_HealthBilanComplications_Field_dopplerArteresMIFS" "Dopller des arteres des MIFS (date/médecin)")
         `LongText ;
  ]	

(* ========================================================================== *)
let healthExamen = profileForm "HealthExamen" 
  ~name:"Examen"
  [ 
     join ~name:"date"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Date" "Date")
         `Date ;
     join ~name:"type"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Type" "Type d'examen")
         `LongText ;
     join ~name:"soignant"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Soignant" "Nom du soignant")
         `LongText ;
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
     join ~name:"douleursMollets"
         ~label:(adlib "ProfileForm_HealthExamen_Field_douleursMollets" "Douleurs des mollets")
         `Checkbox ;
    join ~name:"oedemesPieds"
         ~label:(adlib "ProfileForm_HealthExamen_Field_OedemesPieds" "Oedemes des pieds")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenOedemesPiedsReveil" "Au réveil" ;
			adlib "ProfileFormValuesHealthExamenOedemesPiedsFinJournee" "En fin de journée" ] ) ;
    join ~name:"douleursArticulations"
         ~label:(adlib "ProfileForm_HealthExamen_Field_DouleursArticulations" "Douleurs des articulations")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsOrteils" "Orteils" ;
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsChevilles" "Chevilles" ;
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsGenous" "Genoux" ;
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsHanches" "Hanches" ;
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsEpaules" "Epaules" ;
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsCoudes" "Coudes" ;
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsPoignets" "Poignets" ;
			adlib "ProfileFormValuesHealthExamenDouleursArticulationsDoigts" "Doigts" ] ) ;
     join ~name:"douleursMusculaires"
         ~label:(adlib "ProfileForm_HealthExamen_Field_douleursMusculaires" "Douleurs musculaires")
         `Checkbox ;
    join ~name:"troublesMictionnels"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesMictionnels" "Troubles mictionnels")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenOedemesTroublesMictionnelsBrulure" "Brulure" ;
			adlib "ProfileFormValuesHealthExamenOedemesTroublesMictionnelsPolyurie" "Polyurie" ;
			adlib "ProfileFormValuesHealthExamenOedemesTroublesMictionnelsDysurie" "Dysurie" ;
			adlib "ProfileFormValuesHealthExamenOedemesTroublesMictionnelsNycturie" "Nycturie" ] ) ;
    join ~name:"troublesSexuels"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesSexuels" "Troubles sexuels")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenOedemesTroublesSexuelsEcoulements" "Ecoulements" ;
			adlib "ProfileFormValuesHealthExamenOedemesTroublesSexuelsPrurit" "Prurit" ;
			adlib "ProfileFormValuesHealthExamenOedemesTroublesSexuelsSecheresseVaginale" "Secheresse vaginale" ;
			adlib "ProfileFormValuesHealthExamenOedemesTroublesSexuelsTroublesErection" "Troubles de l’erection" ;
			adlib "ProfileFormValuesHealthExamenOedemesTroublesSexuelsTroublesLibido" "Troubles de la libido" ] ) ;
    join ~name:"troublesDigestifs"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesDigestifs" "Troubles digestifs")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenTroublesDigestifsGaz" "Gaz" ;
			adlib "ProfileFormValuesHealthExamenTroublesDigestifsDiarhee" "Diarhée" ;
			adlib "ProfileFormValuesHealthExamenTroublesDigestifsConstipation" "Constipation" ;
			adlib "ProfileFormValuesHealthExamenTroublesDigestifsSaignement" "Saignement" ] ) ;
     join ~name:"douleurAbdominale"
         ~label:(adlib "ProfileForm_HealthExamen_Field_douleurAbdominale" "Douleur abdominale")
         `Checkbox ;
    join ~name:"dyspnee"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Dyspnee" "Dyspnée")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenDyspneeEffort" "A l'effort" ;
			adlib "ProfileFormValuesHealthExamenDyspneeRepos" "Au repos" ] ) ;
    join ~name:"palpitation"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Palpitation" "Palpitation")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenPalpitationEffort" "A l'effort" ;
			adlib "ProfileFormValuesHealthExamenPalpitationRepos" "Au repos" ] ) ;
    join ~name:"precordialgies"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Precordialgies" "Précordialgies")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenPrecordialgiesEffort" "A l'effort" ;
			adlib "ProfileFormValuesHealthExamenPrecordialgiesRepos" "Au repos" ] ) ;
     join ~name:"troublesDentaires"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesDentaires" "Troubles dentaires")
         `Checkbox ;
     join ~name:"cephalees"
         ~label:(adlib "ProfileForm_HealthExamen_Field_Cephalees" "Céphalées")
         `Checkbox ;
    join ~name:"troublesVisuels"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesVisuels" "Troubles visuels")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenTroublesVisuelsLoin" "De loin" ;
			adlib "ProfileFormValuesHealthExamenTroublesVisuelsPres" "De prés" ] ) ;
     join ~name:"troublesAuditifs"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesAuditifs" "Troubles auditifs")
         `Checkbox ;
    join ~name:"troublesMemoire"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesMemoire" "Troubles de mémoire")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenTroublesMemoireFaitsRecents" "Sur les faits recents" ;
			adlib "ProfileFormValuesHealthExamenTroublesMemoireFaitsAnciens" "Sur les faits anciens" ] ) ;    
    join ~name:"troublesSommeil"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesSommeil" "Troubles du sommeil")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenTroublesSommeilEndormissement" "Endormissement" ;
			adlib "ProfileFormValuesHealthExamenTroublesSommeilReveilsMultiples" "Reveils multiples" ] ) ;
    join ~name:"troublesAppetit"
         ~label:(adlib "ProfileForm_HealthExamen_Field_TroublesAppetit" "Troubles de l'appétit")
		 (`PickMany [
			adlib "ProfileFormValuesHealthExamenTroublesAppetitHyperphagie" "Hyperphagie" ;
			adlib "ProfileFormValuesHealthExamenTroublesAppetitAnorexie" "Anorexie" ] ) ;
     join ~name:"autresPlaintes"
         ~label:(adlib "ProfileForm_HealthExamen_Field_AutresPlaintes" "Autres Plaintes")
         `Textarea ;
  ]

(* ========================================================================== *)
(*  let healthParcours = profileForm "HealthParcours" 
  ~name:"Mon parcours"
  [ 
    join ~name:""
         ~label:(adlib "ProfileForm_HealthParcours_Field_" "Troubles de l'appétit")
		 (`PickMany [
			adlib "ProfileFormValuesHealthParcours" "" ;
			adlib "ProfileFormValuesHealthParcours" "" ] ) ;
  ]	
*)
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
 

