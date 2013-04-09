(* © 2013 RunOrg *)

open Common

(* ========================================================================== *)

let admin = group "Admin"
  ~name:"Groupe des Administrateurs RunOrg"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let groupBadminton = group "GroupBadminton"
  ~name:"Sportifs Badminton"
  ~desc:"Disposez de toutes les informations demandées à vos sportifs dans le cadre du badminton"
  ~columns:Col.([
    status ;
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFormLicenseNumber" ~old:"join.form.license-number" "Numéro de license (si vous en avez un)")
      (`Self (`Field "license-number")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormCompetitor" "Compétiteur")
      (`Self (`Field "competitor")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRanking" "Classement")
      (`Self (`Field "Classement")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable")
      (`Self (`Field "mobilephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse")
      (`Self (`Field "address")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession")
      (`Self (`Field "job")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père")
      (`Self (`Field "info-father")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère")
      (`Self (`Field "info-mother")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ")
      (`Self (`Field "medical-data-sport")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques")
      (`Self (`Field "other")) ;
  ])
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" ~old:"join.form.lastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" ~old:"join.form.firstname" "Prénom") ~required:true `LongText ;
    join ~name:"sex" ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" ~old:"join.form.sex.male" "Masculin" ;
         adlib "JoinFormSexFemale" ~old:"join.form.sex.female" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile") `LongText ;
    join ~name:"job" ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession") `LongText ;
    join ~name:"address" ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable") `LongText ;
    join ~name:"license-number" ~label:(adlib "JoinFormLicenseNumber" ~old:"join.form.license-number" "Numéro de license (si vous en avez un)") `LongText ;
    join ~name:"competitor" ~label:(adlib "JoinFormCompetitor" "Compétiteur") ~required:true 
      (`PickOne [
         adlib "Yes" ~old:"yes" "Oui" ;
         adlib "No" ~old:"no" "Non" ] ) ;
	join ~name:"ranking" ~label:(adlib "JoinFormRanking" "Classement") `LongText ;
	join ~name:"info-mother" ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère") `Textarea ;
    join ~name:"info-father" ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père") `Textarea ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques") `Textarea ;
  ]
  ()
  
(* ========================================================================== *)

let groupCheerleading = group "GroupCheerleading"
  ~name:"Sportifs cheerleaders"
  ~desc:"Grâce à ce groupe vous disposez de toutes les informations demandées à des sportifs dans le cadre du cheerleading"
  ~columns:Col.([
    status ;
    date ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable")
      (`Self (`Field "mobilephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse")
      (`Self (`Field "address")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession")
      (`Self (`Field "job")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOtherSportInfo" ~old:"join.form.other-sport-info" "Durée, niveau et fréquences des sports déjà pratiqués (ex : natation / confirmé / 2 fois semaine)")
      (`Self (`Field "other-sport-info")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormCategoriesChearleading" ~old:"join.form.categories-chearleading" "Catégories")
      (`Self (`Field "categories-chearleading")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormPositionDesired" ~old:"join.form.position-desired" "Poste joué/souhaité")
      (`Self (`Field "position-desired")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père")
      (`Self (`Field "info-father")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère")
      (`Self (`Field "info-mother")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ")
      (`Self (`Field "medical-data-sport")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques")
      (`Self (`Field "other")) ;
  ])
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" ~old:"join.form.lastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" ~old:"join.form.firstname" "Prénom") ~required:true `LongText ;
    join ~name:"sex" ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" ~old:"join.form.sex.male" "Masculin" ;
         adlib "JoinFormSexFemale" ~old:"join.form.sex.female" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile") `LongText ;
    join ~name:"categories-chearleading" ~label:(adlib "JoinFormCategoriesChearleading" ~old:"join.form.categories-chearleading" "Catégories") ~required:true 
      (`PickOne [
         adlib "JoinFormCategoriesChearleadingLess11fun" ~old:"join.form.categories-chearleading.less11fun" "Cheer -11 ans - Loisir" ;
         adlib "JoinFormCategoriesChearleadingLess15fun" ~old:"join.form.categories-chearleading.less15fun" "Cheer -15 ans - Loisir" ;
         adlib "JoinFormCategoriesChearleadingMore15fun" ~old:"join.form.categories-chearleading.more15fun" "Cheer + 15 ans Loisir" ;
         adlib "JoinFormCategoriesChearleadingMore15compete" ~old:"join.form.categories-chearleading.more15compete" "Cheer +15 ans Compétition" ] ) ;
    join ~name:"other-sport-info" ~label:(adlib "JoinFormOtherSportInfo" ~old:"join.form.other-sport-info" "Durée, niveau et fréquences des sports déjà pratiqués (ex : natation / confirmé / 2 fois semaine)") `Textarea ;
    join ~name:"job" ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession") `LongText ;
    join ~name:"address" ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable") `LongText ;
    join ~name:"info-mother" ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère") `Textarea ;
    join ~name:"info-father" ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père") `Textarea ;
    join ~name:"position-desired" ~label:(adlib "JoinFormPositionDesired" ~old:"join.form.position-desired" "Poste joué/souhaité") 
      (`PickMany [
         adlib "JoinFormPositionDesiredSpot" ~old:"join.form.position-desired.spot" "Spot" ;
         adlib "JoinFormPositionDesiredBase" ~old:"join.form.position-desired.base" "Base" ;
         adlib "JoinFormPositionDesiredFlyer" ~old:"join.form.position-desired.flyer" "Flyer" ;
         adlib "JoinFormPositionDesiredCoach" ~old:"join.form.position-desired.coach" "Coach" ] ) ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let _ = group "GroupCollaborative"
  ~name:"Groupe"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = group "GroupCollaborativeAuto"
  ~name:"Groupe"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = group "GroupContact"
  ~name:"Contacts"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let groupCoproEmployes = group "GroupCoproEmployes"
  ~name:"Gardiens / employés"
  ~desc:"Groupe avec forum, dédié aux gardiens et salariés"
  ~columns:Col.([ 
    status ;
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel")
      (`Self (`Field "workphone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWorkmobile" ~old:"join.form.workmobile" "Portable professionnel")
      (`Self (`Field "workmobile")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWorkemail" ~old:"join.form.workemail" "Email professionnel")
      (`Self (`Field "workemail")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormResposabilitiesTasks" ~old:"join.form.resposabilities-tasks" "Responsabilités / tâches")
      (`Self (`Field "resposabilities-tasks")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormDayTimeWorking" ~old:"join.form.day-time-working" "Jours et heures d'interventions")
      (`Self (`Field "day-time-working")) ;
  ])
  ~join:[
    join ~name:"workphone" ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel") `LongText ;
    join ~name:"workmobile" ~label:(adlib "JoinFormWorkmobile" ~old:"join.form.workmobile" "Portable professionnel") `LongText ;
    join ~name:"workemail" ~label:(adlib "JoinFormWorkemail" ~old:"join.form.workemail" "Email professionnel") `LongText ;
    join ~name:"resposabilities-tasks" ~label:(adlib "JoinFormResposabilitiesTasks" ~old:"join.form.resposabilities-tasks" "Responsabilités / tâches") `Textarea ;
    join ~name:"day-time-working" ~label:(adlib "JoinFormDayTimeWorking" ~old:"join.form.day-time-working" "Jours et heures d'interventions") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let groupCoproLodger = group "GroupCoproLodger"
  ~name:"Locataires"
  ~desc:"Groupe dédié aux locataires"
  ~columns:Col.([
    status ;
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~view:`Text
      ~label:(adlib "Mobilephone" ~old:"mobilephone" "")
      (`Self (`Field "mobilephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormAppartment" ~old:"join.form.appartment" "Appartement(s) (batiment, escalier, étage, numéro)")
      (`Self (`Field "appartment")) ;
  ])
  ~join:[
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable") `LongText ;
    join ~name:"appartment" ~label:(adlib "JoinFormAppartment" ~old:"join.form.appartment" "Appartement(s) (batiment, escalier, étage, numéro)") ~required:true `LongText ;
  ]
  ()

(* ========================================================================== *)

let groupCoproManager = group "GroupCoproManager"
  ~name:"Gestionnaires"
  ~desc:"Groupe dédié aux gestionnaires"
  ~columns:Col.([
    status ;
    date ;
    column ~view:`Text
      ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel")
      (`Self (`Field "workphone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWorkmobile" ~old:"join.form.workmobile" "Portable professionnel")
      (`Self (`Field "workmobile")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWorkemail" ~old:"join.form.workemail" "Email professionnel")
      (`Self (`Field "workemail")) ;
  ])
  ~join:[
    join ~name:"workphone" ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel") `LongText ;
    join ~name:"workmobile" ~label:(adlib "JoinFormWorkmobile" ~old:"join.form.workmobile" "Portable professionnel") `LongText ;
    join ~name:"workemail" ~label:(adlib "JoinFormWorkemail" ~old:"join.form.workemail" "Email professionnel") `LongText ;
  ]
  ()

(* ========================================================================== *)

let groupCorproOwner = group "GroupCorproOwner"
  ~name:"Propriétaires"
  ~desc:"Groupe avec forum, dédié aux propriétaires"
  ~columns:Col.([
    status ; 
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~view:`Text
      ~label:(adlib "Mobilephone" ~old:"mobilephone" "")
      (`Self (`Field "mobilephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormAppartment" ~old:"join.form.appartment" "Appartement(s) (batiment, escalier, étage, numéro)")
      (`Self (`Field "appartment")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormNbCoproPart" ~old:"join.form.nb-copro-part" "Nombre de millièmes")
      (`Self (`Field "nb-copro-part")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormLiveCopro" ~old:"join.form.live-copro" "Habitez-vous cet appartement ?")
      (`Self (`Field "live-copro")) ;
  ])
  ~join:[
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable") `LongText ;
    join ~name:"appartment" ~label:(adlib "JoinFormAppartment" ~old:"join.form.appartment" "Appartement(s) (batiment, escalier, étage, numéro)") ~required:true `LongText ;
    join ~name:"nb-copro-part" ~label:(adlib "JoinFormNbCoproPart" ~old:"join.form.nb-copro-part" "Nombre de millièmes") `LongText ;
    join ~name:"live-copro" ~label:(adlib "JoinFormLiveCopro" ~old:"join.form.live-copro" "Habitez-vous cet appartement ?") 
      (`PickOne [
         adlib "Yes" ~old:"yes" "Oui" ;
         adlib "No" ~old:"no" "Non" ] ) ;
  ]
  ()

(* ========================================================================== *)

let groupFitnessMembers = group "GroupFitnessMembers"
  ~name:"Sportifs fitness"
  ~desc:"Regroupe les informations demandées à vos sportifs."
  ~columns:Col.([
    status ;
    date ;
    column ~view:`Text
      ~label:(adlib "ProfileShareConfigPhone" ~old:"profile.share.config.phone" "Numéro de téléphone")
      (`Self (`Field "phone")) ;
    column ~view:`Text
      ~label:(adlib "ProfileShareConfigBirth" ~old:"profile.share.config.birth" "Date de naissance")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormSize" ~old:"join.form.size" "Taille")
      (`Self (`Field "size")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWeight" ~old:"join.form.weight" "Poids")
      (`Self (`Field "weight")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWaistSize" ~old:"join.form.waist-size" "Mensuration : tour de taille")
      (`Self (`Field "waist-size")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormThighSize" ~old:"join.form.thigh-size" "Mensuration : tour de cuisse")
      (`Self (`Field "thigh-size")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormActualLevelSport" ~old:"join.form.actual-level-sport" "Niveau de pratique sportive actuel")
      (`Self (`Field "actual-level-sport")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormObjectives" ~old:"join.form.objectives" "Objectifs")
      (`Self (`Field "objectives")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormActualSports" ~old:"join.form.actual-sports" "Sports pratiqués (ou déjà pratiqués)")
      (`Self (`Field "actual-sports")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOthersports" ~old:"join.form.othersports" "autres sports pratiqués ou déjà pratiqués")
      (`Self (`Field "othersports")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormSessionType" ~old:"join.form.session-type" "Type de séance")
      (`Self (`Field "session-type")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormCourseType" ~old:"join.form.course-type" "Types de cours souhaités")
      (`Self (`Field "course-type")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormNbSession" ~old:"join.form.nb-session" "Nombre séances envisagées hebdomadaires")
      (`Self (`Field "nb-session")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormPreferedSessionTime" ~old:"join.form.prefered-session-time" "Horaires envisagés pour les séances")
      (`Self (`Field "prefered-session-time")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ")
      (`Self (`Field "medical-data-sport")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques")
      (`Self (`Field "other")) ;
  ])
  ~join:[
    join ~name:"phone" ~label:(adlib "ProfileShareConfigPhone" ~old:"profile.share.config.phone" "Numéro de téléphone") ~required:true `LongText ;
    join ~name:"dateofbirth" ~label:(adlib "ProfileShareConfigBirth" ~old:"profile.share.config.birth" "Date de naissance") ~required:true `LongText ;
    join ~name:"size" ~label:(adlib "JoinFormSize" ~old:"join.form.size" "Taille") ~required:true `LongText ;
    join ~name:"weight" ~label:(adlib "JoinFormWeight" ~old:"join.form.weight" "Poids") ~required:true `LongText ;
    join ~name:"waist-size" ~label:(adlib "JoinFormWaistSize" ~old:"join.form.waist-size" "Mensuration : tour de taille") `LongText ;
    join ~name:"thigh-size" ~label:(adlib "JoinFormThighSize" ~old:"join.form.thigh-size" "Mensuration : tour de cuisse") `LongText ;
    join ~name:"actual-level-sport" ~label:(adlib "JoinFormActualLevelSport" ~old:"join.form.actual-level-sport" "Niveau de pratique sportive actuel") ~required:true 
      (`PickOne [
         adlib "JoinFormValuesBeginner" ~old:"join.form.values.beginner" "Débutant" ;
         adlib "JoinFormValuesAthletic" ~old:"join.form.values.athletic" "Sportif" ;
         adlib "JoinFormValuesConfirmed" ~old:"join.form.values.confirmed" "Confirmé" ] ) ;
    join ~name:"objectives" ~label:(adlib "JoinFormObjectives" ~old:"join.form.objectives" "Objectifs") ~required:true 
      (`PickMany [
         adlib "JoinFormObjectivesLoseWeight" ~old:"join.form.objectives.lose-weight" "Perte de poids" ;
         adlib "JoinFormObjectivesRelaxingWellfare" ~old:"join.form.objectives.relaxing-wellfare" "Relaxation & bien être" ;
         adlib "JoinFormObjectivesRelaxation" ~old:"join.form.objectives.relaxation" "Assouplissement" ;
         adlib "JoinFormObjectivesToning" ~old:"join.form.objectives.toning" "Tonification" ;
         adlib "JoinFormObjectivesPerformance" ~old:"join.form.objectives.performance" "Performance" ;
         adlib "JoinFormObjectivesPhysicalPreparation" ~old:"join.form.objectives.physical-preparation" "Préparation physique générale individualisée" ] ) ;
    join ~name:"actual-sports" ~label:(adlib "JoinFormActualSports" ~old:"join.form.actual-sports" "Sports pratiqués (ou déjà pratiqués)") 
      (`PickMany [
         adlib "JoinFormActualSportsJogging" ~old:"join.form.actual-sports.jogging" "Jogging" ;
         adlib "JoinFormActualSportsBiking" ~old:"join.form.actual-sports.biking" "Vélo" ;
         adlib "JoinFormActualSportsRacketSport" ~old:"join.form.actual-sports.racket-sport" "Sport de raquette" ;
         adlib "JoinFormActualSportsCombatSport" ~old:"join.form.actual-sports.combat-sport" "Sport de Combat" ;
         adlib "JoinFormActualSportsIndoorSport" ~old:"join.form.actual-sports.indoor-sport" "Sport en Salle" ;
         adlib "JoinFormActualSportsTeamSport" ~old:"join.form.actual-sports.team-sport" "Sport Collectif" ] ) ;
    join ~name:"othersports" ~label:(adlib "JoinFormOthersports" ~old:"join.form.othersports" "autres sports pratiqués ou déjà pratiqués") `Textarea ;
    join ~name:"session-type" ~label:(adlib "JoinFormSessionType" ~old:"join.form.session-type" "Type de séance") ~required:true 
      (`PickMany [
         adlib "JoinFormSessionTypePrivate" ~old:"join.form.session-type.private" "Individuel" ;
         adlib "JoinFormSessionTypeCollectif" ~old:"join.form.session-type.collectif" "collectif" ;
         adlib "JoinFormSessionTypeAlone" ~old:"join.form.session-type.alone" "Seul (sans coach)" ] ) ;
    join ~name:"course-type" ~label:(adlib "JoinFormCourseType" ~old:"join.form.course-type" "Types de cours souhaités") ~required:true 
      (`PickMany [
         adlib "JoinFormCourseTypeAbsButt" ~old:"join.form.course-type.abs-butt" "Abdos-fessiers" ;
         adlib "JoinFormCourseTypeSoftGym" ~old:"join.form.course-type.soft-gym" "Gym souple" ;
         adlib "JoinFormCourseTypeStep" ~old:"join.form.course-type.step" "Step" ;
         adlib "JoinFormCourseTypeCardio" ~old:"join.form.course-type.cardio" "Cardio" ;
         adlib "JoinFormCourseTypeBoxe" ~old:"join.form.course-type.boxe" "Boxe" ;
         adlib "JoinFormCourseTypeBodybuilding" ~old:"join.form.course-type.bodybuilding" "Musculation" ] ) ;
    join ~name:"nb-session" ~label:(adlib "JoinFormNbSession" ~old:"join.form.nb-session" "Nombre séances envisagées hebdomadaires") ~required:true 
      (`PickOne [
         adlib "1" ~old:"1" "1" ;
         adlib "2" ~old:"2" "2" ;
         adlib "3" ~old:"3" "3" ;
         adlib "4" ~old:"4" "4" ;
         adlib "5" ~old:"5" "5" ] ) ;
    join ~name:"prefered-session-time" ~label:(adlib "JoinFormPreferedSessionTime" ~old:"join.form.prefered-session-time" "Horaires envisagés pour les séances") ~required:true 
      (`PickMany [
         adlib "JoinFormValuesMorning" ~old:"join.form.values.morning" "Matin" ;
         adlib "JoinFormValuesNoon" ~old:"join.form.values.noon" "Midi" ;
         adlib "JoinFormValuesAfternoon" ~old:"join.form.values.afternoon" "Après-midi" ;
         adlib "JoinFormValuesEvening" ~old:"join.form.values.evening" "Soir" ] ) ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let groupFootus = group "GroupFootus"
  ~name:"Sportifs football américain"
  ~desc:"Regroupe les informations demandées aux joueurs de football américain"
  ~columns:Col.([
    status ;
    date ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable")
      (`Self (`Field "mobilephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse")
      (`Self (`Field "address")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession")
      (`Self (`Field "job")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormSize" ~old:"join.form.size" "Taille")
      (`Self (`Field "size")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWeight" ~old:"join.form.weight" "Poids")
      (`Self (`Field "weight")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormExperienceFootus" ~old:"join.form.experience-footus" "Expérience Football Américain")
      (`Self (`Field "experience-footus")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormPositionDesired" ~old:"join.form.position-desired" "Poste joué/souhaité")
      (`Self (`Field "position-desired")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père")
      (`Self (`Field "info-father")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère")
      (`Self (`Field "info-mother")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ")
      (`Self (`Field "medical-data-sport")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques")
      (`Self (`Field "other")) ;
  ])
  ~join:[
    join ~name:"sex" ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" ~old:"join.form.sex.male" "Masculin" ;
         adlib "JoinFormSexFemale" ~old:"join.form.sex.female" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile") `LongText ;
    join ~name:"job" ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession") `LongText ;
    join ~name:"address" ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable") `LongText ;
    join ~name:"size" ~label:(adlib "JoinFormSize" ~old:"join.form.size" "Taille") `LongText ;
    join ~name:"experience-footus" ~label:(adlib "JoinFormExperienceFootus" ~old:"join.form.experience-footus" "Expérience Football Américain") `LongText ;
    join ~name:"weight" ~label:(adlib "JoinFormWeight" ~old:"join.form.weight" "Poids") `LongText ;
    join ~name:"info-mother" ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère") `Textarea ;
    join ~name:"info-father" ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père") `Textarea ;
    join ~name:"position-desired" ~label:(adlib "JoinFormPositionDesired" ~old:"join.form.position-desired" "Poste joué/souhaité") 
      (`PickMany [
         adlib "JoinFormPositionDesiredQb" ~old:"join.form.position-desired.qb" "QB" ;
         adlib "JoinFormPositionDesiredWr" ~old:"join.form.position-desired.wr" "WR" ;
         adlib "JoinFormPositionDesiredRb" ~old:"join.form.position-desired.rb" "RB" ;
         adlib "JoinFormPositionDesiredOl" ~old:"join.form.position-desired.ol" "OL" ;
         adlib "JoinFormPositionDesiredDl" ~old:"join.form.position-desired.dl" "DL" ;
         adlib "JoinFormPositionDesiredLb" ~old:"join.form.position-desired.lb" "LB" ;
         adlib "JoinFormPositionDesiredDb" ~old:"join.form.position-desired.db" "DB" ;
         adlib "JoinFormPositionDesiredCoach" ~old:"join.form.position-desired.coach" "Coach" ] ) ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let groupJudoMembers = group "GroupJudoMembers"
  ~name:"Sportifs judo et jujitsu"
  ~desc:"Regroupe les informations demandées aux pratiquants de judo et de jujitsu"
  ~columns:Col.([
    status ;
    date ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable")
      (`Self (`Field "mobilephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormSize" ~old:"join.form.size" "Taille")
      (`Self (`Field "size")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWeight" ~old:"join.form.weight" "Poids")
      (`Self (`Field "weight")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormGradeJudoJujitsu" ~old:"join.form.grade-judo-jujitsu" "Grade Judo / Jujitsu")
      (`Self (`Field "grade-judo-jujitsu")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormGradeJudoJujitsuDan" ~old:"join.form.grade-judo-jujitsu-dan" "Si ceinture noire, quel dan ?")
      (`Self (`Field "grade-judo-jujitsu-dan")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormPassportJudo" ~old:"join.form.passport-judo" "Disposez-vous d'un passeport Judo ?")
      (`Self (`Field "passport-judo")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormLicenseNumber" ~old:"join.form.license-number" "Numéro de license (si vous en avez un)")
      (`Self (`Field "license-number")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ")
      (`Self (`Field "medical-data-sport")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques")
      (`Self (`Field "other")) ;
  ])
  ~join:[
    join ~name:"sex" ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" ~old:"join.form.sex.male" "Masculin" ;
         adlib "JoinFormSexFemale" ~old:"join.form.sex.female" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable") `LongText ;
    join ~name:"size" ~label:(adlib "JoinFormSize" ~old:"join.form.size" "Taille") ~required:true `LongText ;
    join ~name:"weight" ~label:(adlib "JoinFormWeight" ~old:"join.form.weight" "Poids") ~required:true `LongText ;
    join ~name:"grade-judo-jujitsu" ~label:(adlib "JoinFormGradeJudoJujitsu" ~old:"join.form.grade-judo-jujitsu" "Grade Judo / Jujitsu") ~required:true 
      (`PickOne [
         adlib "JoinFormGradeJudoJujitsuNoneBeginner" ~old:"join.form.grade-judo-jujitsu.none-beginner" "Aucun / débutant" ;
         adlib "JoinFormGradeJudoJujitsuWhite" ~old:"join.form.grade-judo-jujitsu.white" "Ceinture blanche" ;
         adlib "JoinFormGradeJudoJujitsuWhiteYellow" ~old:"join.form.grade-judo-jujitsu.white-yellow" "Ceinture blanche/jaune " ;
         adlib "JoinFormGradeJudoJujitsuYellow" ~old:"join.form.grade-judo-jujitsu.yellow" "Ceinture jaune" ;
         adlib "JoinFormGradeJudoJujitsuYellowOrange" ~old:"join.form.grade-judo-jujitsu.yellow-orange" "Ceinture jaune/orange" ;
         adlib "JoinFormGradeJudoJujitsuOrange" ~old:"join.form.grade-judo-jujitsu.orange" "Ceinture orange" ;
         adlib "JoinFormGradeJudoJujitsuOrangeGreen" ~old:"join.form.grade-judo-jujitsu.orange-green" "Ceinture orange/verte" ;
         adlib "JoinFormGradeJudoJujitsuGreen" ~old:"join.form.grade-judo-jujitsu.green" "Ceinture verte" ;
         adlib "JoinFormGradeJudoJujitsuBlue" ~old:"join.form.grade-judo-jujitsu.blue" "Ceinture bleue" ;
         adlib "JoinFormGradeJudoJujitsuBrown" ~old:"join.form.grade-judo-jujitsu.brown" "Ceinture marron" ;
         adlib "JoinFormGradeJudoJujitsuBlack" ~old:"join.form.grade-judo-jujitsu.black" "Ceinture noire" ] ) ;
    join ~name:"grade-judo-jujitsu-dan" ~label:(adlib "JoinFormGradeJudoJujitsuDan" ~old:"join.form.grade-judo-jujitsu-dan" "Si ceinture noire, quel dan ?") 
      (`PickOne [
         adlib "JoinFormGradeJudoJujitsuDan1dan" ~old:"join.form.grade-judo-jujitsu-dan.1dan" "1er dan" ;
         adlib "JoinFormGradeJudoJujitsuDan2dan" ~old:"join.form.grade-judo-jujitsu-dan.2dan" "2nd dan" ;
         adlib "JoinFormGradeJudoJujitsuDan3dan" ~old:"join.form.grade-judo-jujitsu-dan.3dan" "3eme dan" ;
         adlib "JoinFormGradeJudoJujitsuDan4dan" ~old:"join.form.grade-judo-jujitsu-dan.4dan" "4eme dan" ;
         adlib "JoinFormGradeJudoJujitsuDan5dan" ~old:"join.form.grade-judo-jujitsu-dan.5dan" "5eme dan" ;
         adlib "JoinFormGradeJudoJujitsuDan6dan" ~old:"join.form.grade-judo-jujitsu-dan.6dan" "6eme dan" ] ) ;
    join ~name:"passport-judo" ~label:(adlib "JoinFormPassportJudo" ~old:"join.form.passport-judo" "Disposez-vous d'un passeport Judo ?") ~required:true 
      (`PickOne [
         adlib "Yes" ~old:"yes" "Oui" ;
         adlib "No" ~old:"no" "Non" ] ) ;
    join ~name:"license-number" ~label:(adlib "JoinFormLicenseNumber" ~old:"join.form.license-number" "Numéro de license (si vous en avez un)") `LongText ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let groupRespo = group "GroupRespo"
  ~name:"Responsables"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let groupSchoolParents = group "GroupSchoolParents"
  ~name:"Parents d'élèves"
  ~desc:"Groupe avec forum, dédié aux parents d'élèves"
  ~columns:Col.([
    column ~view:`Text
      ~label:(adlib "JoinFormChildrenNames" "Prénom et Nom des enfants scolarisés")
      (`Self (`Field "children-names")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel")
      (`Self (`Field "workphone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMobile" ~old:"join.form.mobile" "Tel portable")
      (`Self (`Field "mobile")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormWorkemail" ~old:"join.form.workemail" "Email professionnel")
      (`Self (`Field "workemail")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormChildrenGrades" "Classes des enfants scolarisés")
      (`Self (`Field "children-grades")) ;
  ])
  ~join:[
    join ~name:"workphone" ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel") `LongText ;
    join ~name:"mobile" ~label:(adlib "JoinFormMobile" ~old:"join.form.mobile" "Tel portable") `LongText ;
    join ~name:"workemail" ~label:(adlib "JoinFormWorkemail" ~old:"join.form.workemail" "Email professionnel") `LongText ;
	join ~name:"children-names" ~label:(adlib "JoinFormChildrenNames" "Prénom et Nom des enfants scolarisés") ~required:true `LongText ;
	join ~name:"children-grades" ~label:(adlib "JoinFormChildrenGrades" "Classes des enfants scolarisés") 
      (`PickMany [
         adlib "JoinFormChildrenGradesCp" "CP" ;
         adlib "JoinFormChildrenGradesCe1" "CE1" ;
         adlib "JoinFormChildrenGradesCe2" "CE2" ;
         adlib "JoinFormChildrenGradesCm1" "Cm1" ;
         adlib "JoinFormChildrenGradesCm2" "Cm2" ;] ) ;
  ]
  ()
  
(* ========================================================================== *)

let groupSimple = group "GroupSimple"
  ~name:"Groupe Standard"
  ~desc:"Un sous-ensemble des membres de votre espace"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let groupTennis = group "GroupTennis"
  ~name:"Sportifs Tennis"
  ~desc:"Disposez de toutes les informations demandées à vos sportifs dans le cadre du tennis"
  ~columns:Col.([
    status ;
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFormLicenseNumber" ~old:"join.form.license-number" "Numéro de license (si vous en avez un)")
      (`Self (`Field "license-number")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormCompetitor" "Compétiteur")
      (`Self (`Field "competitor")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRanking" "Classement")
      (`Self (`Field "Classement")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable")
      (`Self (`Field "mobilephone")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse")
      (`Self (`Field "address")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession")
      (`Self (`Field "job")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père")
      (`Self (`Field "info-father")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère")
      (`Self (`Field "info-mother")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ")
      (`Self (`Field "medical-data-sport")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques")
      (`Self (`Field "other")) ;
  ])
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" ~old:"join.form.lastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" ~old:"join.form.firstname" "Prénom") ~required:true `LongText ;
    join ~name:"sex" ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" ~old:"join.form.sex.male" "Masculin" ;
         adlib "JoinFormSexFemale" ~old:"join.form.sex.female" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile") `LongText ;
    join ~name:"job" ~label:(adlib "JoinFormJob" ~old:"join.form.job" "Profession") `LongText ;
    join ~name:"address" ~label:(adlib "JoinFormAddress" ~old:"join.form.address" "Adresse") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" ~old:"join.form.mobilephone" "Tel portable") `LongText ;
    join ~name:"license-number" ~label:(adlib "JoinFormLicenseNumber" ~old:"join.form.license-number" "Numéro de license (si vous en avez un)") `LongText ;
    join ~name:"competitor" ~label:(adlib "JoinFormCompetitor" "Compétiteur") ~required:true 
      (`PickOne [
         adlib "Yes" ~old:"yes" "Oui" ;
         adlib "No" ~old:"no" "Non" ] ) ;
	join ~name:"ranking" ~label:(adlib "JoinFormRanking" "Classement") `LongText ;
	join ~name:"info-mother" ~label:(adlib "JoinFormInfoMother" ~old:"join.form.info-mother" "Si mineur : téléphone, email et profession de la mère") `Textarea ;
    join ~name:"info-father" ~label:(adlib "JoinFormInfoFather" ~old:"join.form.info-father" "Si mineur : téléphone, email et profession du père") `Textarea ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" ~old:"join.form.medical-data-sport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" ~old:"join.form.other" "Autres remarques") `Textarea ;
  ]
  ()
  

(* ========================================================================== *)

let _ = group "GroupTest"
  ~name:"Groupe Test"
  ()

(* ========================================================================== *)

let _ = group "SubscriptionAuto"
  ~name:"Adhésion"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let subscriptionDatetodate = group "SubscriptionDatetodate"
  ~name:"Adhésion"
  ~desc:"Date à date : annuelle, semestrielle, etc"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = group "SubscriptionDatetodateAuto"
  ~name:"Adhésion date à date automatique"
  ~desc:"Aucune validation par un responsable n’est nécessaire pour qu’un membre adhère. Adhésion avec une date de début et de fin de validité"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let subscriptionForever = group "SubscriptionForever"
  ~name:"Adhésion Permanente"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = group "SubscriptionForeverAuto"
  ~name:"Adhésion permanente automatique"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = group "SubscriptionSemester"
  ~name:"Adhésion Semestrielle"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = group "SubscriptionYear"
  ~name:"Adhésion Annuelle"
  ~columns:Col.([ status ; date ])
  ()

