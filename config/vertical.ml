(* © 2012 RunOrg *)
open Common 

(* ========================================================================== *)

let _ = vertical "Test"
  ~old:"test"
  ~name:"Association Test"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([
  ])
  Template.([
    eventSimple ;
  ])
;;

(* ========================================================================== *)

let _ = vertical "Ag"
  ~old:"v:ag"
  ~name:"Assemblées Générales"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "test-group" groupSimple
      ~name:(adlib "CatalogFreeTrial" ~old:"catalog.free-trial" "Essai Gratuit") ;
  ])
  Template.([
    eventAg ;
    eventMeeting ;
  ])
;;

(* ========================================================================== *)

let athle = vertical "Athle"
  ~old:"v:athle"
  ~name:"Club d'athlétisme"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.group-collaborative.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
	initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces")  ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
 initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes")  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors") ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors") ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let badminton = vertical "Badminton"
  ~name:"Clubs de Badminton"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.group-collaborative.badminton-players.name" groupBadminton
      ~name:(adlib "EntitySampleGroupCollaborativeBadmintonPlayersName" "Joueurs de Badminton") ;
    initial "entity.sample.group-collaborative.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.group-collaborative.badminton-competition.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeBadmintonCompetitorsName" "Compétition") ;
    initial "entity.sample.group-collaborative.badminton-fun.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeBadmintonFunName" "Loisir") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    groupBadminton ;
    eventBadmintonCompetition ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let campaigns = vertical "Campaigns" 
  ~old:"v:campaigns"
  ~name:"Campagnes électorales"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.group-collaborative.campaign-comity.sample" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCampaignComitySample" ~old:"entity.sample.group-collaborative.campaign-comity.sample" "Comité de campagne") ;
    initial "entity.sample.group-collaborative.campaign-members.sample" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCampaignMembersSample" ~old:"entity.sample.group-collaborative.campaign-members.sample" "Militants") ;
    initial "entity.sample.group-collaborative.campaign-sympathisers.sample" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCampaignSympathisersSample" ~old:"entity.sample.group-collaborative.campaign-sympathisers.sample" "Sympathisants") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventCampaignAction ;
    eventCampaignMeeting ;
  ])
;;

(* ========================================================================== *)

let citizenPortal = vertical "CitizenPortal"
  ~old:"v:citizen-portal"
  ~name:"Portail citoyens"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicCommittee ;
  ])
;;

(* ========================================================================== *)

let collectivites = vertical "Collectivites"
  ~old:"v:collectivites"
  ~name:"Mairies & collectivités"
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces")  ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.collectivites-agent.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesAgentName" ~old:"entity.sample.group-collaborative.collectivites-agent.name" "Agents") ;
    initial "entity.sample.group-collaborative.collectivites-manager.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesManagerName" ~old:"entity.sample.group-collaborative.collectivites-manager.name" "Responsables de service") ;
    initial "entity.sample.group-collaborative.collectivites-mayor.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesMayorName" ~old:"entity.sample.group-collaborative.collectivites-mayor.name" "Cabinet du maire") ;
    initial "entity.sample.group-collaborative.collectivites-dep-sport.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesDepSportName" ~old:"entity.sample.group-collaborative.collectivites-dep-sport.name" "Service des sports") ;
    initial "entity.sample.group-collaborative.collectivites-dep-culture.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesDepCultureName" ~old:"entity.sample.group-collaborative.collectivites-dep-culture.name" "Service culturel") ;
    initial "entity.sample.group-collaborative.collectivites-conseillers-municipaux.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesConseillersMunicipauxName" ~old:"entity.sample.group-collaborative.collectivites-conseillers-municipaux.name" "Conseillers municipaux") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicCommittee ;
  ])
;;

(* ========================================================================== *)

let comiteEnt = vertical "ComiteEnt"
  ~old:"v:comite-ent"
  ~name:"Comités d'entreprise"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.comite-ent-employees.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeComiteEntEmployeesName" ~old:"entity.sample.group-collaborative.comite-ent-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.comite-ent-managers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeComiteEntManagersName" ~old:"entity.sample.group-collaborative.comite-ent-managers.name" "Elus du CE")  ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventComiteEnt ;
  ])
;;

(* ========================================================================== *)

let company = vertical "Company"
  ~old:"v:company"
  ~name:"Entreprises"
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.company-employees.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.company-management.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let companyTraining = vertical "CompanyTraining"
  ~old:"v:company-training"
  ~name:"Sociétés de formation"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") ;
    initial "entity.sample.group-collaborative.company-employees.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.company-management.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") ;
    initial "entity.sample.group-collaborative.company-trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyTrainersName" ~old:"entity.sample.group-collaborative.company-trainers.name" "Formateurs") ;
    initial "entity.sample.group-collaborative.company-trainees.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyTraineesName" ~old:"entity.sample.group-collaborative.company-trainees.name" "Stagiaires") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    courseStage ;
    courseTraining ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let copro = vertical "Copro"
  ~old:"v:copro"
  ~name:"Copropriété avec syndic professionnel"
  ~forms:ProfileForm.([ simple ])
  Template.([
   initial "entity.sample.group-collaborative.copro.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCoproName" ~old:"entity.sample.group-collaborative.copro.name" "Membres du syndic") ; 
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-copro-owner.name" groupCorproOwner
      ~name:(adlib "EntitySampleGroupCoproOwnerName" ~old:"entity.sample.group-copro-owner.name" "Propriétaires") ;
    initial "entity.sample.group-copro-manager.name" groupCoproManager
      ~name:(adlib "EntitySampleGroupCoproManagerName" ~old:"entity.sample.group-copro-manager.name" "Gestionnaires") ;
    initial "entity.sample.group-copro-lodger.name" groupCoproLodger
      ~name:(adlib "EntitySampleGroupCoproLodgerName" ~old:"entity.sample.group-copro-lodger.name" "Locataires") ;
    initial "entity.sample.group-copro-employes.name" groupCoproEmployes
      ~name:(adlib "EntitySampleGroupCoproEmployesName" ~old:"entity.sample.group-copro-employes.name" "Gardiens / employés") ;
  ])
  Template.([
    groupCorproOwner ;
    groupSimple ;
    groupCollaborative ;
    groupCoproLodger ;
    groupCoproEmployes ;
    groupCoproManager ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventCoproMeeting ;
  ])
;;

(* ========================================================================== *)

let coproVolunteer = vertical "CoproVolunteer"
  ~old:"v:copro-volonteer"
  ~name:"Copropriété avec syndic bénévole"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.group-collaborative.copro.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCoproName" ~old:"entity.sample.group-collaborative.copro.name" "Membres du syndic") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-copro-owner.name" groupCorproOwner
      ~name:(adlib "EntitySampleGroupCoproOwnerName" ~old:"entity.sample.group-copro-owner.name" "Propriétaires") ;
    initial "entity.sample.group-copro-lodger.name" groupCoproLodger
      ~name:(adlib "EntitySampleGroupCoproLodgerName" ~old:"entity.sample.group-copro-lodger.name" "Locataires")  ;
    initial "entity.sample.group-copro-employes.name" groupCoproEmployes
      ~name:(adlib "EntitySampleGroupCoproEmployesName" ~old:"entity.sample.group-copro-employes.name" "Gardiens / employés") ;
  ])
 Template.([
    groupCorproOwner ;
    groupSimple ;
    groupCollaborative ;
    groupCoproLodger ;
    groupCoproEmployes ;
    groupCoproManager ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventCoproMeeting ;
  ])
;;

(* ========================================================================== *)

let elementarySchool = vertical "ElementarySchool"
  ~name:"Ecoles primaires"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.school-teachers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolTeachersName" "Enseignants et équipe éducative") ;
    initial "entity.sample.group-collaborative.school-parents.name" groupSchoolParents
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolParentsName" "Parents d'élèves") ;
    initial "entity.sample.group-collaborative.school-grade-cp.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCpName" "Classe de CP") ;
    initial "entity.sample.group-collaborative.school-grade-ce1.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCe1Name" "Classe de CE1") ;
    initial "entity.sample.group-collaborative.school-grade-ce2.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCe2Name" "Classe de CE2") ;
    initial "entity.sample.group-collaborative.school-grade-cm1.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCm1Name" "Classe de CM1") ;
    initial "entity.sample.group-collaborative.school-grade-cm2.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCm2Name" "Classe de CM2") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
  ])
;;

(* ========================================================================== *)

let ess = vertical "Ess"
  ~old:"v:ess"
  ~name:"Association Economie Sociale et Solidaire"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let events = vertical "Events"
  ~old:"v:events"
  ~name:"Organisation d'évènements"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.staff.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeStaffName" ~old:"entity.sample.group-collaborative.staff.name" "Staff") ;
    initial "entity.sample.contact.name" groupSimple
      ~name:(adlib "EntitySampleContactName" ~old:"entity.sample.contact.name" "Contacts") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventClubbing ;
    eventAfterwork ;
    eventSimple ;
    eventMeeting ;
  ])
;;

(* ========================================================================== *)

let federations = vertical "Federations"
  ~old:"v:federations"
  ~name:"Fédérations"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.federation-structure.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationStructureName" ~old:"entity.sample.group-collaborative.federation-structure.name" "Structure fédérale") ;
    initial "entity.sample.group-collaborative.federation-dtn.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationDtnName" ~old:"entity.sample.group-collaborative.federation-dtn.name" "Direction Technique Nationale") ;
    initial "entity.sample.group-collaborative.federation-comite.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationComiteName" ~old:"entity.sample.group-collaborative.federation-comite.name" "Comité directeur") ;
    initial "entity.sample.group-collaborative.federation-clubs-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationClubsAssoName" ~old:"entity.sample.group-collaborative.federation-clubs-asso.name" "Clubs & associations affiliés") ;
    initial "entity.sample.group-collaborative.federation-presidents.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationPresidentsName" ~old:"entity.sample.group-collaborative.federation-presidents.name" "Présidents de clubs et d'asso affiliés") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let football = vertical "Football"
  ~old:"v:football"
  ~name:"Football"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([ ])
  Template.([
    groupSimple ;
    groupRespo ;
    pollSimple ;
    eventSimple ;
  ])
;;

(* ========================================================================== *)

let footus = vertical "Footus"
  ~old:"v:footus"
  ~name:"Football américain et cheerleading"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.group-collaborative.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraîneurs et formateurs");
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-footus.name" groupFootus
      ~name:(adlib "EntitySampleGroupFootusName" ~old:"entity.sample.group-footus.name" "Joueurs football américain") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.group-cheerleading.name" groupCheerleading
      ~name:(adlib "EntitySampleGroupCheerleadingName" ~old:"entity.sample.group-cheerleading.name" "Cheerleaders") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.forum-public.jobs-sport.name" forum
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors")  ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes")  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors")  ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    groupCheerleading ;
    groupFootus ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let impro = vertical "Impro"
  ~old:"v:impro"
  ~name:"Théâtre d'Improvisation"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventImproSimple ;
    eventImproSpectacle ;
    eventMeeting ;
    eventAg ;
  ])
;;

(* ========================================================================== *)

let judo = vertical "Judo"
  ~old:"v:judo"
  ~name:"Club de judo et jujitsu"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.group-collaborative.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-judo-members.name" groupJudoMembers
      ~name:(adlib "EntitySampleGroupJudoMembersName" ~old:"entity.sample.group-judo-members.name" "Sportifs judo et jujitsu") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.forum-public.jobs-sport.name" forum
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") ;
    initial "entity.sample.sport.group-petitssamourais.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPetitssamouraisName" ~old:"entity.sample.sport.group-petitssamourais.name" "Petits samouraïs") ;
    initial "entity.sample.sport.group-poussinnets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinnetsName" ~old:"entity.sample.sport.group-poussinnets.name" "Poussinets") ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes")  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets")  ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors")  ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors")  ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") ;
  ])
  Template.([
    groupJudoMembers ;
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventJudoCompetition ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let light = vertical "Light"
  ~old:"v:light"
  ~name:"RunOrg Light"
  ~forms:ProfileForm.([ simple ])
  Template.([
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let localDemocracy = vertical "LocalDemocracy"
  ~old:"v:local-democracy"
  ~name:"Conseils de quartiers"
  ~archive:true
  Template.([
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    forum ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicCommittee ;
  ])
;;

(* ========================================================================== *)

let localNpPortal = vertical "LocalNpPortal"
  ~old:"v:local-np-portal"
  ~name:"Portail associatif communal"
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.mda-resp-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespAssoName" ~old:"entity.sample.group-collaborative.mda-resp-asso.name" "Responsables d'associations") ;
    initial "entity.sample.group-collaborative.mda-resp-commune.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespCommuneName" ~old:"entity.sample.group-collaborative.mda-resp-commune.name" "Responsables municipaux") ;
    initial "entity.sample.group-collaborative.mda-member-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaMemberAssoName" ~old:"entity.sample.group-collaborative.mda-member-asso.name" "Membres d'associations") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicCommittee ;
  ])
;;

(* ========================================================================== *)

let maisonAsso = vertical "MaisonAsso"
  ~old:"v:maison-asso"
  ~name:"Maison des associations"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.mda-resp-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespAssoName" ~old:"entity.sample.group-collaborative.mda-resp-asso.name" "Responsables d'associations") ;
    initial "entity.sample.group-collaborative.mda-resp-commune.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespCommuneName" ~old:"entity.sample.group-collaborative.mda-resp-commune.name" "Responsables municipaux") ;
    initial "entity.sample.group-collaborative.mda-member-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaMemberAssoName" ~old:"entity.sample.group-collaborative.mda-member-asso.name" "Membres d'associations") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let multiSports = vertical "MultiSports"
  ~old:"v:multi-sports"
  ~name:"Club multi-sports"
  Template.([
    initial "entity.sample.group-collaborative.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.forum-public.jobs-sport.name" forum
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes") ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors")  ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors")  ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") ;
  ])
  Template.([
    groupCollaborative ;
    groupSimple ;
    groupJudoMembers ;
    groupFitnessMembers ;
    groupCheerleading ;
    groupFootus ;
    groupBadminton ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventBadmintonCompetition ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let rugby = vertical "Rugby"
  ~old:"v:rugby"
  ~name:"Rugby"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([ ])
  Template.([
    groupSimple ;
    groupRespo ;
    pollSimple ;
    eventSimple ;
  ])
;;

(* ========================================================================== *)

let runorg = vertical "Runorg"
  ~old:"v:runorg"
  ~name:"RunOrg"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([ ])
  Template.([
    groupSimple ;
    groupRespo ;
    groupCollaborative ;
    groupCollaborativeAuto ;
    pollSimple ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let salleSport = vertical "SalleSport"
  ~old:"v:salle-sport"
  ~name:"Salle de sport et Coaching sportif"
  Template.([
      initial "entity.sample.group-collaborative.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-fitness-members.name" groupFitnessMembers
      ~name:(adlib "EntitySampleGroupFitnessMembersName" ~old:"entity.sample.group-fitness-members.name" "Sportifs Fitness") ;
    initial "entity.sample.group-collaborative.staff.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeStaffName" ~old:"entity.sample.group-collaborative.staff.name" "Staff") ;
  ])
  Template.([
    groupSimple ;
    groupFitnessMembers ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    course12sessionsFitness ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
  ])
;;

(* ========================================================================== *)

let sectionSportEtudes = vertical "SectionSportEtudes"
  ~name:"Section Sport-études"
  ~forms:ProfileForm.([ 
		sectionSportEtudesBilan ; 
		sectionSportEtudesCompetition_Judo ; 
		sectionSportEtudesMedical ;
		sectionSportEtudesTrainings ;
		sectionSportEtudesAcademic ;
		simple	])
  Template.([
    initial "entity.sample.group-collaborative.sectionsportetudes.sportifs.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesSportifsName" "Elèves et sportifs") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.management-team.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesManagementTeamName" "Equipe encadrante") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesTrainersName" "Entraîneurs") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.teachers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesTeachersName" "Professeurs") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.medical-team.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesMedicalTeamName" "Equipe médicale") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.parents.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesParentsName" "Parents des sportifs") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg")
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventJudoCompetition ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let simple = vertical "Simple"
  ~old:"v:simple"
  ~name:"RunOrg Standard"
  ~forms:ProfileForm.([ simple ; test ])
  Template.([
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg")
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let spUsep = vertical "SpUsep"
  ~old:"v:sp-usep"
  ~name:"Fédération - USEP"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-collaborative.federation-structure.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationStructureName" ~old:"entity.sample.group-collaborative.federation-structure.name" "Structure fédérale") ;
    initial "entity.sample.group-collaborative.federation-dtn.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationDtnName" ~old:"entity.sample.group-collaborative.federation-dtn.name" "Direction Technique Nationale") ;
    initial "entity.sample.group-collaborative.federation-comite.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationComiteName" ~old:"entity.sample.group-collaborative.federation-comite.name" "Comité directeur") ;
    initial "entity.sample.group-collaborative.federation-clubs-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationClubsAssoName" ~old:"entity.sample.group-collaborative.federation-clubs-asso.name" "Clubs & associations affiliés") ;
    initial "entity.sample.group-collaborative.federation-presidents.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationPresidentsName" ~old:"entity.sample.group-collaborative.federation-presidents.name" "Présidents de clubs et d'asso affiliés") ;
  ])
  Template.([
    groupCollaborative ;
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventSimple ;
  ])
;;

(* ========================================================================== *)

let sports = vertical "Sports"
  ~old:"v:sports"
  ~name:"Autre sport"
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.group-collaborative.trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.forum-public.jobs-sport.name" forum
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes")  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors") ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors") ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") ;
  ])
  Template.([
    groupSimple ;
    groupCollaborative ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
  ])
;;

(* ========================================================================== *)

let sportsTest = vertical "SportsTest"
  ~old:"v:sports-test"
  ~name:"undefined"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([

  ])
  Template.([
  ])
;;

(* ========================================================================== *)

let standard = vertical "Standard"
  ~old:"v:standard"
  ~name:"undefined"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([
  ])
  Template.([
  ])
;;

(* ========================================================================== *)

let stub = vertical "Stub"
  ~old:"v:stub"
  ~name:"Profil uniquement"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  Template.([
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") ;
  ])
  Template.([
  ])
;;

(* ========================================================================== *)

let students = vertical "Students"
  ~old:"v:students"
  ~name:"Associations étudiantes"
  ~forms:ProfileForm.([ simple ])
  Template.([
      initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.forum-public.classified.name" forum
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") ;
    initial "entity.sample.forum-public.user-support.name" forum
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") ;
  ])
  Template.([
    groupCollaborative ;
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventClubbing ;
    eventPetition ;
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
              (adlib "VerticalStudentsName" "Associations étudiantes")
              (Some (adlib "VerticalStudentsDesc" 
		       "Pour les BDE, les BDA, les BDS et les assos étudiantes"));
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
    inCatalog badminton
              (adlib "VerticalBadminton" "Club de badminton")
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
    (* inCatalog localDemocracy
              (adlib "VerticalLocalDemocracyName" "Conseils de quartiers")
              None ; *)
    inCatalog maisonAsso
              (adlib "VerticalMaisonAssoName" "Maison des associations")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Fed" "Fédérations") [
    inCatalog federations
              (adlib "VerticalFederationName" "Fédérations")
              None ;
    inCatalog spUsep
              (adlib "VerticalSpUsepName" "Fédération - USEP")
              None ;
    inCatalog sectionSportEtudes
              (adlib "SectionSportEtudes" "Sections Sport-études")
              (Some (adlib "VerticalCatalogSectionSportEtudesDesc" 
		       "Gestion des classes sportives : encadrement, parents, élèves")) ;
  ] ;
  subCatalog ~name:(adlib "Education" "Education") [
    inCatalog elementarySchool
              (adlib "VerticalElementarySchool" "Ecoles primaires")
              None ;
    inCatalog sectionSportEtudes
              (adlib "SectionSportEtudes" "Sections Sport-études")
              (Some (adlib "VerticalCatalogSectionSportEtudesDesc" 
		       "Gestion des classes sportives : encadrement, parents, élèves")) ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Syndic" "Syndics de copropriétés") [
    inCatalog copro
              (adlib "VerticalCoproName" "Copropriété avec syndic professionnel")
              None ;
    inCatalog coproVolunteer
              (adlib "VerticalCoproVolonteerName" "Copropriété avec syndic bénévole")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Pro" "Entreprises") [
    inCatalog company
              (adlib "VerticalCompanyName" "Entreprises")
              None ;
    inCatalog companyTraining
              (adlib "VerticalCompanyTrainingName" "Centres de formation")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Ce" "Comités d'entreprise") [
    inCatalog comiteEnt
              (adlib "VerticalComiteEntName" "Comités d'entreprise")
              None ;
  ] ;
  subCatalog ~name:(adlib "Catalog_Autre" "Autres") [
    inCatalog events
              (adlib "VerticalEventsName" "Organisation d'évènements")
              None ;
    (* inCatalog citizenPortal
              (adlib "VerticalCitizenPortalName" "Portail citoyens")
              None ; *)
    inCatalog simple
              (adlib "VerticalCatalogOtherName" "Autres")
              None ;
  ] ;
] ;;
