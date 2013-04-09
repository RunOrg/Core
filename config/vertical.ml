(* © 2013 RunOrg *)

open Common 

open Groups
open Events

(* ========================================================================== *)

let _ = vertical "Test"
  ~old:"test"
  ~name:"Association Test"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [
  ]
  [ 
    eventSimple 
  ]
;;

(* ========================================================================== *)

let _ = vertical "Ag"
  ~old:"v:ag"
  ~name:"Assemblées Générales"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [
    initial "test-group" groupSimple
      ~name:(adlib "CatalogFreeTrial" ~old:"catalog.free-trial" "Essai Gratuit") ;
  ]
  [
    eventAg ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let athle = vertical "Athle"
  ~old:"v:athle"
  ~name:"Club d'athlétisme"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:Adlib.OldEntity.group_poussins ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:Adlib.OldEntity.group_benjamins ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:Adlib.OldEntity.group_minimes  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:Adlib.OldEntity.group_cadets ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:Adlib.OldEntity.group_juniors ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:Adlib.OldEntity.group_seniors ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:Adlib.OldEntity.group_veterans ;
  ]
  [
    groupSimple ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
  ]
;;

(* ========================================================================== *)

let badminton = vertical "Badminton"
  ~name:"Clubs de Badminton"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.group-collaborative.badminton-players.name" groupBadminton
      ~name:(adlib "EntitySampleGroupCollaborativeBadmintonPlayersName" "Joueurs de Badminton") ;
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.group-collaborative.badminton-competition.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeBadmintonCompetitorsName" "Compétition") ;
    initial "entity.sample.group-collaborative.badminton-fun.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeBadmintonFunName" "Loisir") ;
  ]
  [
    groupSimple ;
    groupBadminton ;
    eventBadmintonCompetition ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
  ]
;;

(* ========================================================================== *)

let campaigns = vertical "Campaigns" 
  ~old:"v:campaigns"
  ~name:"Campagnes électorales"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.campaign-comity.sample" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCampaignComitySample" ~old:"entity.sample.group-collaborative.campaign-comity.sample" "Comité de campagne") ;
    initial "entity.sample.group-collaborative.campaign-members.sample" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCampaignMembersSample" ~old:"entity.sample.group-collaborative.campaign-members.sample" "Militants") ;
    initial "entity.sample.group-collaborative.campaign-sympathisers.sample" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCampaignSympathisersSample" ~old:"entity.sample.group-collaborative.campaign-sympathisers.sample" "Sympathisants") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventCampaignAction ;
    eventCampaignMeeting ;
  ]
;;

(* ========================================================================== *)

let citizenPortal = vertical "CitizenPortal"
  ~old:"v:citizen-portal"
  ~name:"Portail citoyens"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicCommittee ;
  ]
;;

(* ========================================================================== *)

let collectivites = vertical "Collectivites"
  ~old:"v:collectivites"
  ~name:"Mairies & collectivités"
  [
    initial "entity.sample.group-collaborative.collectivites-agent.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesAgentName" ~old:"entity.sample.group-collaborative.collectivites-agent.name" "Agents") ;
    initial "entity.sample.group-collaborative.collectivites-manager.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesManagerName" ~old:"entity.sample.group-collaborative.collectivites-manager.name" "Responsables de service") ;
    initial "entity.sample.group-collaborative.collectivites-mayor.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesMayorName" ~old:"entity.sample.group-collaborative.collectivites-mayor.name" "Cabinet du maire") ;
    initial "entity.sample.group-collaborative.collectivites-dep-sport.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesDepSportName" ~old:"entity.sample.group-collaborative.collectivites-dep-sport.name" "Service des sports") ;
    initial "entity.sample.group-collaborative.collectivites-dep-culture.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesDepCultureName" ~old:"entity.sample.group-collaborative.collectivites-dep-culture.name" "Service culturel") ;
    initial "entity.sample.group-collaborative.collectivites-conseillers-municipaux.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesConseillersMunicipauxName" ~old:"entity.sample.group-collaborative.collectivites-conseillers-municipaux.name" "Conseillers municipaux") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventPublicCommittee ;
  ]
;;

(* ========================================================================== *)

let comiteEnt = vertical "ComiteEnt"
  ~old:"v:comite-ent"
  ~name:"Comités d'entreprise"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.comite-ent-employees.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeComiteEntEmployeesName" ~old:"entity.sample.group-collaborative.comite-ent-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.comite-ent-managers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeComiteEntManagersName" ~old:"entity.sample.group-collaborative.comite-ent-managers.name" "Elus du CE")  ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventComiteEnt ;
  ]
;;

(* ========================================================================== *)

let company = vertical "Company"
  ~old:"v:company"
  ~name:"Entreprises"
  [
    initial "entity.sample.group-collaborative.company-employees.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.company-management.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let companyCRM = vertical "CompanyCRM"
   ~name:"CRM - Portail client"
  [
    initial "entity.sample.group-collaborative.company-employees.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.company-management.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") ;
    initial "entity.sample.group-collaborative.companycrm-customers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyCRMCustomersName" "Clients") ;
    initial "entity.sample.group-collaborative.companycrm-customersvip.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyCRMCustomersVipName" "Clients VIP") ;
    initial "entity.sample.group-collaborative.companycrm-partners.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyCRMParnersName" "Partenaires") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let companyTraining = vertical "CompanyTraining"
  ~old:"v:company-training"
  ~name:"Sociétés de formation"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.company-management.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") ;
    initial "entity.sample.group-collaborative.company-trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyTrainersName" ~old:"entity.sample.group-collaborative.company-trainers.name" "Formateurs") ;
    initial "entity.sample.group-collaborative.company-trainees.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyTraineesName" ~old:"entity.sample.group-collaborative.company-trainees.name" "Stagiaires") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    courseStage ;
    courseTraining ;
    eventSimple ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let companyPress = vertical "CompanyPress"
   ~name:"Presse"
  [
    initial "entity.sample.group-collaborative.company-employees.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") ;
    initial "entity.sample.group-collaborative.company-management.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") ;
    initial "entity.sample.group-collaborative.companypress-subscribers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyPressSubscribersName" "Abonnés") ;
    initial "entity.sample.group-collaborative.companypress-readers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyPressReadersName" "Lecteurs") ;
    initial "entity.sample.group-collaborative.companypress-newsletter.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyPressNewsletterName" "Abonnés NewsLetter") ;
    initial "entity.sample.group-collaborative.companypress-advertisers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyPressAdvertiserName" "Annonceurs") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let copro = vertical "Copro"
  ~old:"v:copro"
  ~name:"Copropriété avec syndic professionnel"
  ~forms:ProfileForm.([ simple ])
  [
   initial "entity.sample.group-collaborative.copro.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCoproName" ~old:"entity.sample.group-collaborative.copro.name" "Membres du syndic") ; 
    initial "entity.sample.group-copro-owner.name" groupCorproOwner
      ~name:Adlib.OldEntity.group_copro_owner ;
    initial "entity.sample.group-copro-manager.name" groupCoproManager
      ~name:(adlib "EntitySampleGroupCoproManagerName" ~old:"entity.sample.group-copro-manager.name" "Gestionnaires") ;
    initial "entity.sample.group-copro-lodger.name" groupCoproLodger
      ~name:Adlib.OldEntity.group_copro_lodger ;
    initial "entity.sample.group-copro-employes.name" groupCoproEmployes
      ~name:Adlib.OldEntity.group_copro_employes ;
  ]
  [
    groupCorproOwner ;
    groupSimple ;
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
  ]
;;

(* ========================================================================== *)

let coproVolunteer = vertical "CoproVolunteer"
  ~old:"v:copro-volonteer"
  ~name:"Copropriété avec syndic bénévole"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.copro.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeCoproName" ~old:"entity.sample.group-collaborative.copro.name" "Membres du syndic") ;
    initial "entity.sample.group-copro-owner.name" groupCorproOwner
      ~name:Adlib.OldEntity.group_copro_owner ;
    initial "entity.sample.group-copro-lodger.name" groupCoproLodger
      ~name:Adlib.OldEntity.group_copro_lodger  ;
    initial "entity.sample.group-copro-employes.name" groupCoproEmployes
      ~name:Adlib.OldEntity.group_copro_employes ;
  ]
  [
    groupCorproOwner ;
    groupSimple ;
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
  ]
;;

(* ========================================================================== *)

let elementarySchool = vertical "ElementarySchool"
  ~name:"Ecoles primaires"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.school-teachers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolTeachersName" "Enseignants et équipe éducative") ;
    initial "entity.sample.group-collaborative.school-parents.name" groupSchoolParents
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolParentsName" "Parents d'élèves") ;
    initial "entity.sample.group-collaborative.school-grade-cp.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCpName" "Classe de CP") ;
    initial "entity.sample.group-collaborative.school-grade-ce1.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCe1Name" "Classe de CE1") ;
    initial "entity.sample.group-collaborative.school-grade-ce2.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCe2Name" "Classe de CE2") ;
    initial "entity.sample.group-collaborative.school-grade-cm1.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCm1Name" "Classe de CM1") ;
    initial "entity.sample.group-collaborative.school-grade-cm2.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSchoolGradeCm2Name" "Classe de CM2") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let ess = vertical "Ess"
  ~old:"v:ess"
  ~name:"Association Economie Sociale et Solidaire"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ]
;;

(* ========================================================================== *)

let events = vertical "Events"
  ~old:"v:events"
  ~name:"Organisation d'évènements"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.staff.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeStaffName" ~old:"entity.sample.group-collaborative.staff.name" "Staff") ;
    initial "entity.sample.contact.name" groupSimple
      ~name:(adlib "EntitySampleContactName" ~old:"entity.sample.contact.name" "Contacts") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventClubbing ;
    eventAfterwork ;
    eventSimple ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let federations = vertical "Federations"
  ~old:"v:federations"
  ~name:"Fédérations"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.federation-structure.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationStructureName" ~old:"entity.sample.group-collaborative.federation-structure.name" "Structure fédérale") ;
    initial "entity.sample.group-collaborative.federation-dtn.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationDtnName" ~old:"entity.sample.group-collaborative.federation-dtn.name" "Direction Technique Nationale") ;
    initial "entity.sample.group-collaborative.federation-comite.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationComiteName" ~old:"entity.sample.group-collaborative.federation-comite.name" "Comité directeur") ;
    initial "entity.sample.group-collaborative.federation-clubs-asso.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationClubsAssoName" ~old:"entity.sample.group-collaborative.federation-clubs-asso.name" "Clubs & associations affiliés") ;
    initial "entity.sample.group-collaborative.federation-presidents.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationPresidentsName" ~old:"entity.sample.group-collaborative.federation-presidents.name" "Présidents de clubs et d'asso affiliés") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
  ]
;;

(* ========================================================================== *)

let football = vertical "Football"
  ~old:"v:football"
  ~name:"Football"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [
  ]
  [
    groupSimple ;
    groupRespo ;
    pollSimple ;
    eventSimple ;
  ]
;;

(* ========================================================================== *)

let footus = vertical "Footus"
  ~old:"v:footus"
  ~name:"Football américain et cheerleading"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraîneurs et formateurs");
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-footus.name" groupFootus
      ~name:(adlib "EntitySampleGroupFootusName" ~old:"entity.sample.group-footus.name" "Joueurs football américain") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.group-cheerleading.name" groupCheerleading
      ~name:(adlib "EntitySampleGroupCheerleadingName" ~old:"entity.sample.group-cheerleading.name" "Cheerleaders") ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:Adlib.OldEntity.group_seniors  ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:Adlib.OldEntity.group_minimes  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:Adlib.OldEntity.group_cadets ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:Adlib.OldEntity.group_juniors  ;
  ]
  [
    groupSimple ;
    groupCheerleading ;
    groupFootus ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
  ]
;;

(* ========================================================================== *)

let impro = vertical "Impro"
  ~old:"v:impro"
  ~name:"Théâtre d'Improvisation"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventImproSimple ;
    eventImproSpectacle ;
    eventMeeting ;
    eventAg ;
  ]
;;

(* ========================================================================== *)

let judo = vertical "Judo"
  ~old:"v:judo"
  ~name:"Club de judo et jujitsu"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-judo-members.name" groupJudoMembers
      ~name:(adlib "EntitySampleGroupJudoMembersName" ~old:"entity.sample.group-judo-members.name" "Sportifs judo et jujitsu") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.sport.group-petitssamourais.name" groupSimple
      ~name:Adlib.OldEntity.group_petitssamourais ;
    initial "entity.sample.sport.group-poussinnets.name" groupSimple
      ~name:Adlib.OldEntity.group_poussinets ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:Adlib.OldEntity.group_poussins ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:Adlib.OldEntity.group_benjamins ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:Adlib.OldEntity.group_minimes  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:Adlib.OldEntity.group_cadets  ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:Adlib.OldEntity.group_juniors  ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:Adlib.OldEntity.group_seniors  ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:Adlib.OldEntity.group_veterans ;
  ]
  [
    groupJudoMembers ;
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventJudoCompetition ;
    eventAg ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let light = vertical "Light"
  ~old:"v:light"
  ~name:"RunOrg Light"
  ~forms:ProfileForm.([ simple ])
  [
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
  ]
;;

(* ========================================================================== *)

let localDemocracy = vertical "LocalDemocracy"
  ~old:"v:local-democracy"
  ~name:"Conseils de quartiers"
  ~archive:true
  [
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
    eventPublicCommittee ;
  ]
;;

(* ========================================================================== *)

let localNpPortal = vertical "LocalNpPortal"
  ~old:"v:local-np-portal"
  ~name:"Portail associatif communal"
  [
    initial "entity.sample.group-collaborative.mda-resp-asso.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespAssoName" ~old:"entity.sample.group-collaborative.mda-resp-asso.name" "Responsables d'associations") ;
    initial "entity.sample.group-collaborative.mda-resp-commune.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespCommuneName" ~old:"entity.sample.group-collaborative.mda-resp-commune.name" "Responsables municipaux") ;
    initial "entity.sample.group-collaborative.mda-member-asso.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeMdaMemberAssoName" ~old:"entity.sample.group-collaborative.mda-member-asso.name" "Membres d'associations") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventPublicCommittee ;
  ]
;;

(* ========================================================================== *)

let maisonAsso = vertical "MaisonAsso"
  ~old:"v:maison-asso"
  ~name:"Maison des associations"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.mda-resp-asso.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespAssoName" ~old:"entity.sample.group-collaborative.mda-resp-asso.name" "Responsables d'associations") ;
    initial "entity.sample.group-collaborative.mda-resp-commune.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespCommuneName" ~old:"entity.sample.group-collaborative.mda-resp-commune.name" "Responsables municipaux") ;
    initial "entity.sample.group-collaborative.mda-member-asso.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeMdaMemberAssoName" ~old:"entity.sample.group-collaborative.mda-member-asso.name" "Membres d'associations") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let health = vertical "Health"
  ~name:"Santé & médical "
  ~forms:ProfileForm.([ 
		simple ; 
		healthAntecedents ;
		healthParcours ;
		healthExamen ;
		healthBilanComplications ])
  [
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ]
;;

(* ========================================================================== *)


let multiSports = vertical "MultiSports"
  ~old:"v:multi-sports"
  ~name:"Club multi-sports"
  [
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:Adlib.OldEntity.group_poussins ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:Adlib.OldEntity.group_benjamins ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:Adlib.OldEntity.group_minimes ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:Adlib.OldEntity.group_cadets ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:Adlib.OldEntity.group_juniors  ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:Adlib.OldEntity.group_seniors  ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:Adlib.OldEntity.group_veterans ;
  ]
  [
    groupSimple ;
    groupJudoMembers ;
    groupFitnessMembers ;
    groupCheerleading ;
    groupFootus ;
    groupBadminton ;
    groupTennis ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventBadmintonCompetition ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let rugby = vertical "Rugby"
  ~old:"v:rugby"
  ~name:"Rugby"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [ 
  ]
  [
    groupSimple ;
    groupRespo ;
    pollSimple ;
    eventSimple ;
  ]
;;

(* ========================================================================== *)

let runorg = vertical "Runorg"
  ~old:"v:runorg"
  ~name:"RunOrg"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [ 
  ]
  [
    groupSimple ;
    groupRespo ;
    groupSimple ;
    pollSimple ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventPetition ;
  ]
;;

(* ========================================================================== *)

let salleSport = vertical "SalleSport"
  ~old:"v:salle-sport"
  ~name:"Salle de sport et Coaching sportif"
  [
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-fitness-members.name" groupFitnessMembers
      ~name:(adlib "EntitySampleGroupFitnessMembersName" ~old:"entity.sample.group-fitness-members.name" "Sportifs Fitness") ;
    initial "entity.sample.group-collaborative.staff.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeStaffName" ~old:"entity.sample.group-collaborative.staff.name" "Staff") ;
  ]
  [
    groupSimple ;
    groupFitnessMembers ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    course12sessionsFitness ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
  ]
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
  [
    initial "entity.sample.group-collaborative.sectionsportetudes.sportifs.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesSportifsName" "Elèves et sportifs") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.management-team.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesManagementTeamName" "Equipe encadrante") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesTrainersName" "Entraîneurs") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.teachers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesTeachersName" "Professeurs") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.medical-team.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesMedicalTeamName" "Equipe médicale") ;
    initial "entity.sample.group-collaborative.sectionsportetudes.parents.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeSectionSportEtudesParentsName" "Parents des sportifs") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventJudoCompetition ;
    eventMeeting ;
    eventAg ;
  ]
;;

(* ========================================================================== *)

let simple = vertical "Simple"
  ~old:"v:simple"
  ~name:"RunOrg Standard"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
    eventPetition ;
  ]
;;

(* ========================================================================== *)

let spUsep = vertical "SpUsep"
  ~old:"v:sp-usep"
  ~name:"Fédération - USEP"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-collaborative.federation-structure.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationStructureName" ~old:"entity.sample.group-collaborative.federation-structure.name" "Structure fédérale") ;
    initial "entity.sample.group-collaborative.federation-dtn.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationDtnName" ~old:"entity.sample.group-collaborative.federation-dtn.name" "Direction Technique Nationale") ;
    initial "entity.sample.group-collaborative.federation-comite.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationComiteName" ~old:"entity.sample.group-collaborative.federation-comite.name" "Comité directeur") ;
    initial "entity.sample.group-collaborative.federation-clubs-asso.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationClubsAssoName" ~old:"entity.sample.group-collaborative.federation-clubs-asso.name" "Clubs & associations affiliés") ;
    initial "entity.sample.group-collaborative.federation-presidents.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeFederationPresidentsName" ~old:"entity.sample.group-collaborative.federation-presidents.name" "Présidents de clubs et d'asso affiliés") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventAg ;
    eventMeeting ;
    eventPetition ;
    eventSimple ;
  ]
;;

(* ========================================================================== *)

let sports = vertical "Sports"
  ~old:"v:sports"
  ~name:"Autre sport"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:Adlib.OldEntity.group_poussins ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:Adlib.OldEntity.group_benjamins ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:Adlib.OldEntity.group_minimes  ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:Adlib.OldEntity.group_cadets ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:Adlib.OldEntity.group_juniors ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:Adlib.OldEntity.group_seniors ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:Adlib.OldEntity.group_veterans ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
  ]
;;

(* ========================================================================== *)

let sportsTest = vertical "SportsTest"
  ~old:"v:sports-test"
  ~name:"undefined"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [
  ]
  [
  ]
;;

(* ========================================================================== *)

let standard = vertical "Standard"
  ~old:"v:standard"
  ~name:"undefined"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [
  ]
  [
  ]
;;

(* ========================================================================== *)

let stub = vertical "Stub"
  ~old:"v:stub"
  ~name:"Profil uniquement"
  ~archive:true
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") ;
  ]
  [
  ]
;;

(* ========================================================================== *)

let students = vertical "Students"
  ~old:"v:students"
  ~name:"Associations étudiantes"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
  ]
  [
    groupSimple ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    eventSimple ;
    eventAg ;
    eventMeeting ;
    eventClubbing ;
    eventPetition ;
  ]
;;

(* ========================================================================== *)

let tennis = vertical "Tennis"
  ~name:"Clubs de Tennis"
  ~forms:ProfileForm.([ simple ])
  [
    initial "entity.sample.sub-runorg.name" groupSimple
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérents 2012-2013") ;
    initial "entity.sample.group-collaborative.office.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") ;
    initial "entity.sample.group-collaborative.tennis-players.name" groupTennis
      ~name:(adlib "EntitySampleGroupCollaborativeTennisPlayersName" "Joueurs de Tennis") ;
    initial "entity.sample.group-collaborative.trainers.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTrainersName" ~old:"entity.sample.group-collaborative.trainers.name" "Entraineurs et formateurs") ;
    initial "entity.sample.group-collaborative.tennis-competition.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTennisCompetitorsName" "Compétition") ;
    initial "entity.sample.group-collaborative.tennis-fun.name" groupSimple
      ~name:(adlib "EntitySampleGroupCollaborativeTennisFunName" "Loisir") ;
  ]
  [
    groupSimple ;
    groupTennis ;
    pollSimple ;
    pollYearly ;
    courseSimple ;
    course12sessions ;
    eventSimple ;
    eventMeeting ;
    eventAg ;
  ]
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
    inCatalog tennis
              (adlib "VerticalTennis" "Club de tennis")
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
    inCatalog companyPress
              (adlib "VerticalCompanyPressName" "Presse")
              None ;
    inCatalog companyCRM
              (adlib "VerticalCompanyCRMName" "CRM")
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
    inCatalog simple
              (adlib "VerticalCatalogOtherName" "Autres")
              None ;
    inCatalog health
              (adlib "VerticalCatalogHealthName" "Santé & médical")
              None ;
  ] ;
] ;;
