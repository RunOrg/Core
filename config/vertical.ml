(* © 2012 RunOrg *)
open Common

(* ========================================================================== *)

let test = vertical "Test"
  ~old:"test"
  ~name:"Association Test"
  ~archive:true
  Template.([
    groupTest ;
    eventSimple ;
  ])
;;

(* ========================================================================== *)

let ag = vertical "Ag"
  ~old:"v:ag"
  ~name:"Assemblées Générales"
  ~archive:true
  Template.([
    eventAg ;
    eventMeeting ;
  ])
;;

(* ========================================================================== *)

let athle = vertical "Athle"
  ~old:"v:athle"
  ~name:"Club d'athlétisme"
  Template.([
    groupSimple ;
    groupCollaborative ;
    groupCheerleading ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let campaigns = vertical "Campaigns"
  ~old:"v:campaigns"
  ~name:"Campagnes électorales"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventCampaignAction ;
    eventCampaignMeeting ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let citizenPortal = vertical "CitizenPortal"
  ~old:"v:citizen-portal"
  ~name:"Portail citoyens"
  ~archive:true
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicComity ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let collectivites = vertical "Collectivites"
  ~old:"v:collectivites"
  ~name:"Mairies & collectivités"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicComity ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let comiteEnt = vertical "ComiteEnt"
  ~old:"v:comite-ent"
  ~name:"Comités d'entreprise"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventComiteEnt ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let company = vertical "Company"
  ~old:"v:company"
  ~name:"Entreprises"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let companyTraining = vertical "CompanyTraining"
  ~old:"v:company-training"
  ~name:"Sociétés de formation"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    courseStage ;
    courseTraining ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let copro = vertical "Copro"
  ~old:"v:copro"
  ~name:"Copropriété avec syndic professionnel"
  Template.([
    groupCorproOwner ;
    groupSimple ;
    groupCollaborative ;
    groupCoproLodger ;
    groupCoproEmployes ;
    groupCoproManager ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventCoproMeeting ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let coproVolonteer = vertical "CoproVolonteer"
  ~old:"v:copro-volonteer"
  ~name:"Copropriété avec syndic bénévole"
  Template.([
  ])
;;

(* ========================================================================== *)

let ess = vertical "Ess"
  ~old:"v:ess"
  ~name:"Association Economie Sociale et Solidaire"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let events = vertical "Events"
  ~old:"v:events"
  ~name:"Organisation d'évènements"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventClubbing ;
    eventAfterwork ;
    eventSimple ;
    eventMeeting ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let federations = vertical "Federations"
  ~old:"v:federations"
  ~name:"Fédérations"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let football = vertical "Football"
  ~old:"v:football"
  ~name:"Football"
  ~archive:true
  Template.([
    groupSimple ;
    groupRespo ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    eventSimple ;
    subscriptionYear ;
    subscriptionSemester ;
    subscriptionForever ;
    subscriptionAuto ;
  ])
;;

(* ========================================================================== *)

let footus = vertical "Footus"
  ~old:"v:footus"
  ~name:"Football américain et cheerleading"
  Template.([
    groupSimple ;
    groupCollaborative ;
    groupCheerleading ;
    groupFootus ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let impro = vertical "Impro"
  ~old:"v:impro"
  ~name:"Théâtre d'Improvisation"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventImproSimple ;
    eventImproSpectacle ;
    eventMeeting ;
    eventAg ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let judo = vertical "Judo"
  ~old:"v:judo"
  ~name:"Club de judo et jujitsu"
  Template.([
    groupJudoMembers ;
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let light = vertical "Light"
  ~old:"v:light"
  ~name:"RunOrg Light"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let localDemocracy = vertical "LocalDemocracy"
  ~old:"v:local-democracy"
  ~name:"Conseils de quartiers"
  ~archive:true
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicComity ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let localNpPortal = vertical "LocalNpPortal"
  ~old:"v:local-np-portal"
  ~name:"Portail associatif communal"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicComity ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let maisonAsso = vertical "MaisonAsso"
  ~old:"v:maison-asso"
  ~name:"Maison des associations"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let multiSports = vertical "MultiSports"
  ~old:"v:multi-sports"
  ~name:"Club multi-sports"
  Template.([
    groupCollaborative ;
    groupSimple ;
    groupJudoMembers ;
    groupFitnessMembers ;
    groupCheerleading ;
    groupFootus ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    subscriptionForever ;
    subscriptionDatetodate ;
  ])
;;

(* ========================================================================== *)

let rugby = vertical "Rugby"
  ~old:"v:rugby"
  ~name:"Rugby"
  ~archive:true
  Template.([
    groupSimple ;
    groupRespo ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    eventSimple ;
    subscriptionYear ;
    subscriptionSemester ;
    subscriptionForever ;
    subscriptionAuto ;
  ])
;;

(* ========================================================================== *)

let runorg = vertical "Runorg"
  ~old:"v:runorg"
  ~name:"undefined"
  ~archive:true
  Template.([
    groupSimple ;
    groupRespo ;
    groupCollaborative ;
    groupCollaborativeAuto ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventSimpleAuto ;
    eventPetition ;
    subscriptionYear ;
    subscriptionSemester ;
    subscriptionForever ;
    subscriptionAuto ;
  ])
;;

(* ========================================================================== *)

let salleSport = vertical "SalleSport"
  ~old:"v:salle-sport"
  ~name:"Salle de sport et Coaching sportif"
  Template.([
    groupSimple ;
    groupFitnessMembers ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    course12sessionsFitness ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let simple = vertical "Simple"
  ~old:"v:simple"
  ~name:"RunOrg Standard"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let spUsep = vertical "SpUsep"
  ~old:"v:sp-usep"
  ~name:"Fédération - USEP"
  Template.([
    groupCollaborative ;
    groupSimple ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    course12sessions ;
    courseSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventSimple ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let sports = vertical "Sports"
  ~old:"v:sports"
  ~name:"Autre sport"
  Template.([
    groupSimple ;
    groupCollaborative ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let sportsTest = vertical "SportsTest"
  ~old:"v:sports-test"
  ~name:"undefined"
  ~archive:true
  Template.([
  ])
;;

(* ========================================================================== *)

let standard = vertical "Standard"
  ~old:"v:standard"
  ~name:"undefined"
  ~archive:true
  Template.([
  ])
;;

(* ========================================================================== *)

let stub = vertical "Stub"
  ~old:"v:stub"
  ~name:"Profil uniquement"
  ~archive:true
  Template.([
  ])
;;

(* ========================================================================== *)

let students = vertical "Students"
  ~old:"v:students"
  ~name:"Association étudiante"
  Template.([
    groupCollaborative ;
    groupSimple ;
    forumPublic ;
    albumSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventClubbing ;
    eventClubbing ;
    eventPetition ;
    subscriptionDatetodate ;
    subscriptionForever ;
  ])
;;

(* ========================================================================== *)

let () = catalog [
  subCatalog ~name:(adlib "Catalog_Asso" "Associations") [
    inCatalog simple
              (adlib "VerticalCatalogStandardName" "Standard")
              (Some (adlib "VerticalCatalogStandardDesc" 
		       "Une préconfiguration généraliste adaptée à toutes les associations")) ;
    inCatalog students
              (adlib "VerticalStudentsName" "Association étudiante")
              None ;
    inCatalog ess
              (adlib "VerticalEssName" "Economie Sociale et Solidaire")
              None ;
    inCatalog impro
              (adlib "VerticalImproName" "Théâtre d'Improvisation")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Sport" "Clubs de sport") [
    inCatalog multiSports
              (adlib "VerticalMultiSportsName" "Club multi-sports")
              None ;
    inCatalog judo
              (adlib "VerticalJudoName" "Club de judo et jujitsu")
              None ;
    inCatalog footus
              (adlib "VerticalFootusName" "Football américain et cheerleading")
              None ;
    inCatalog athle
              (adlib "VerticalAthleName" "Club d'athlétisme")
              None ;
    inCatalog salleSport
              (adlib "VerticalSalleSportName" "Salle de sport et Coaching sportif")
              None ;
    inCatalog sports
              (adlib "VerticalSportsName" "Autre sport")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Collec" "Collectivités territoriales") [
    inCatalog collectivites
              (adlib "VerticalCollectivitesName" "Mairies & collectivités")
              None ;
    inCatalog localNpPortal
              (adlib "VerticalLocalNpPortalName" "Portail associatif communal")
              None ;
    inCatalog campaigns
              (adlib "VerticalCampaignsName" "Campagnes électorales")
              None ;
    inCatalog localDemocracy
              (adlib "VerticalLocalDemocracyName" "Conseils de quartiers")
              None ;
    inCatalog maisonAsso
              (adlib "VerticalMaisonAssoName" "Maison des associations")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Syndic" "Syndics de copropriétés") [
    inCatalog copro
              (adlib "VerticalCoproName" "Copropriété avec syndic professionnel")
              None ;
    inCatalog coproVolonteer
              (adlib "VerticalCoproVolonteerName" "Copropriété avec syndic bénévole")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Pro" "Entreprises") [
    inCatalog company
              (adlib "VerticalCompanyName" "Entreprises")
              None ;
    inCatalog companyTraining
              (adlib "VerticalCompanyTrainingName" "Sociétés de formation")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Ce" "Comités d'entreprise") [
    inCatalog comiteEnt
              (adlib "VerticalComiteEntName" "Comités d'entreprise")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Fed" "Fédérations") [
    inCatalog federations
              (adlib "VerticalFederationName" "Fédérations")
              None ;
    inCatalog spUsep
              (adlib "VerticalSpUsepName" "Fédération - USEP")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Autre" "Autres") [
    inCatalog campaigns
              (adlib "VerticalCampaignsName" "Campagnes électorales")
              None ;
    inCatalog events
              (adlib "VerticalEventsName" "Organisation d'évènements")
              None ;
    inCatalog citizenPortal
              (adlib "VerticalCitizenPortalName" "Portail citoyens")
              None ;
    inCatalog simple
              (adlib "VerticalCatalogOtherName" "Autres")
              None ;
  ] ;
] ;;
