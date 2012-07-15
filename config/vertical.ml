(* © 2012 RunOrg *)
open Common 

(* ========================================================================== *)

let test = vertical "Test"
  ~old:"test"
  ~name:"Association Test"
  ~archive:true
  Template.([
  ])
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
    initial "test-group" groupSimple
      ~name:(adlib "CatalogFreeTrial" ~old:"catalog.free-trial" "Essai Gratuit") [
      ] ;
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
  Template.([
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérants 2012-2013") [
       ] ;
	initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
 initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") [
       "desc", "Groupe des responsables de l'association. Les administrateurs et les membres du bureau de l'association peuvent échanger en toute confidentialité dans ce groupe. Pour pouvoir accèder au contenu de ce groupe un administrateur doit inviter les personnes ou valider leur demande d'inscription." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la création de votre espace RunOrg." ;
      ] ;
   initial "entity.sample.event-ag.name" eventAg
      ~name:(adlib "EntitySampleEventAgName" ~old:"entity.sample.event-ag.name" "Exemple d'AG dans RunOrg") [
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre assemblée générale.    1. Ce champ est également disponible avec le modèle des réunions    2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours    3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier    4. Etc." ;
      ] ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à l'association. Toutes les adhésions envoient automatiquement leurs membres vers ce groupe." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
  ])
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

  ])
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
  ])
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
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2011-2012") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.group-collaborative.collectivites-agent.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesAgentName" ~old:"entity.sample.group-collaborative.collectivites-agent.name" "Agents") [
       "desc", "Groupe des agents" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.collectivites-manager.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesManagerName" ~old:"entity.sample.group-collaborative.collectivites-manager.name" "Responsables de services") [
       "desc", "Groupe des responsables de service" ;
       "moreinfo", "" ;
      ] ;
    initial "entity.sample.group-collaborative.collectivites-mayor.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesMayorName" ~old:"entity.sample.group-collaborative.collectivites-mayor.name" "Cabinet du maire") [
       "", "Groupe des membres du cabinet du maire" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.collectivites-dep-sport.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesDepSportName" ~old:"entity.sample.group-collaborative.collectivites-dep-sport.name" "Service des sports") [
       "desc", "Groupe des membres du service des sports" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.collectivites-dep-culture.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesDepCultureName" ~old:"entity.sample.group-collaborative.collectivites-dep-culture.name" "Service culturel") [
       "desc", "Groupe des membres du service culturel" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.collectivites-conseillers-municipaux.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCollectivitesConseillersMunicipauxName" ~old:"entity.sample.group-collaborative.collectivites-conseillers-municipaux.name" "Conseillers municipaux") [
       "desc", "Groupe des conseillers municipaux" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
  ])
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

  ])
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
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.group-collaborative.company-employees.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") [
       "desc", "Groupe des salariés" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.company-management.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") [
       "desc", "Groupe de la direction et du management" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
  ])
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
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.group-collaborative.company-employees.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyEmployeesName" ~old:"entity.sample.group-collaborative.company-employees.name" "Salariés") [
       "desc", "Groupe des salariés" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.company-management.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyManagementName" ~old:"entity.sample.group-collaborative.company-management.name" "Direction & management") [
       "desc", "Groupe de la direction et du management" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.company-trainers.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyTrainersName" ~old:"entity.sample.group-collaborative.company-trainers.name" "Formateurs") [
       "desc", "Groupe des formateurs" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.company-trainees.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCompanyTraineesName" ~old:"entity.sample.group-collaborative.company-trainees.name" "Stagiaires") [
       "desc", "Groupe des Stagiaires" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
  ])
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
   initial "entity.sample.group-collaborative.copro.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCoproName" ~old:"entity.sample.group-collaborative.copro.name" "Membres du syndic") [
       "desc", "Groupe des personnes membres du conseil syndical." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2011-2012") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.event-copro-meeting.name" eventCoproMeeting
      ~name:(adlib "EntitySampleEventCoproMeetingName" ~old:"entity.sample.event-copro-meeting.name" "Exemple de Conseil syndical") [
       "desc", "Nous avons créé automatiquement cet évènement de type \"Conseil syndical\" pour vous montrer à quoi cela ressemble dans RunOrg. Vous pouvez vous à tout moment en créer un en cliquant sur \"Créer un évènement\" et sélectionner \"Conseil syndical\". Cliquez sur \"Inscription\" pour visualiser le formulaire d'inscription qui est proposé aux participants." ;
       "date", "20121231" ;
       "location", "Chez le président du conseil" ;
       "address", "22 rue planchat 75020 Paris" ;
       "coord", "Julien (du A 23)" ;
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre conseil syndical. 1. Ce champ est également disponible avec le modèle des réunions 2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours 3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier 4. Etc.\" " ;
       "moreinfo", "Ce conseil syndical a été créé automatiquement lors de la mise à disposition de votre espace RunOrg " ;
      ] ;
    initial "entity.sample.group-copro-owner.name" groupCorproOwner
      ~name:(adlib "EntitySampleGroupCoproOwnerName" ~old:"entity.sample.group-copro-owner.name" "Propriétaires") [
      ] ;
    initial "entity.sample.group-copro-manager.name" groupCoproManager
      ~name:(adlib "EntitySampleGroupCoproManagerName" ~old:"entity.sample.group-copro-manager.name" "Gestionnaires") [
      ] ;
    initial "entity.sample.group-copro-lodger.name" groupCoproLodger
      ~name:(adlib "EntitySampleGroupCoproLodgerName" ~old:"entity.sample.group-copro-lodger.name" "Locataires") [
      ] ;
    initial "entity.sample.group-copro-employes.name" groupCoproEmployes
      ~name:(adlib "EntitySampleGroupCoproEmployesName" ~old:"entity.sample.group-copro-employes.name" "Gardiens / employés") [
      ] ;
  ])
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
    initial "entity.sample.group-collaborative.copro.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeCoproName" ~old:"entity.sample.group-collaborative.copro.name" "Membres du syndic") [
       "desc", "Groupe des personnes membres du conseil syndical." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2011-2012") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.event-copro-meeting.name" eventCoproMeeting
      ~name:(adlib "EntitySampleEventCoproMeetingName" ~old:"entity.sample.event-copro-meeting.name" "Exemple de Conseil syndical") [
       "desc", "Nous avons créé automatiquement cet évènement de type \"Conseil syndical\" pour vous montrer à quoi cela ressemble dans RunOrg. Vous pouvez vous à tout moment en créer un en cliquant sur \"Créer un évènement\" et sélectionner \"Conseil syndical\". Cliquez sur \"Inscription\" pour visualiser le formulaire d'inscription qui est proposé aux participants." ;
       "date", "20121231" ;
       "location", "Chez le président du conseil" ;
       "address", "22 rue planchat 75020 Paris" ;
       "coord", "Julien (du A 23)" ;
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre conseil syndical. 1. Ce champ est également disponible avec le modèle des réunions 2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours 3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier 4. Etc.\" " ;
       "moreinfo", "Ce conseil syndical a été créé automatiquement lors de la mise à disposition de votre espace RunOrg " ;
      ] ;
    initial "entity.sample.group-copro-owner.name" groupCorproOwner
      ~name:(adlib "EntitySampleGroupCoproOwnerName" ~old:"entity.sample.group-copro-owner.name" "Propriétaires") [
      ] ;
    initial "entity.sample.group-copro-lodger.name" groupCoproLodger
      ~name:(adlib "EntitySampleGroupCoproLodgerName" ~old:"entity.sample.group-copro-lodger.name" "Locataires") [
      ] ;
    initial "entity.sample.group-copro-employes.name" groupCoproEmployes
      ~name:(adlib "EntitySampleGroupCoproEmployesName" ~old:"entity.sample.group-copro-employes.name" "Gardiens / employés") [
      ] ;
  ])
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

let ess = vertical "Ess"
  ~old:"v:ess"
  ~name:"Association Economie Sociale et Solidaire"
  Template.([
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérants 2012-2013") [
       ] ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") [
       "desc", "Groupe des responsables de l'association. Les administrateurs et les membres du bureau de l'association peuvent échanger en toute confidentialité dans ce groupe. Pour pouvoir accèder au contenu de ce groupe un administrateur doit inviter les personnes ou valider leur demande d'inscription." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la création de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.event-simple.name" eventSimple
      ~name:(adlib "EntitySampleEventSimpleName" ~old:"entity.sample.event-simple.name" "Exemple d'évènement dans RunOrg") [
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.petition.name" eventPetition
      ~name:(adlib "EntitySamplePetitionName" ~old:"entity.sample.petition.name" "Exemple de pétition") [
       "desc", "Cette pétition a été créé pour vous montrer le modèle d'évènement \"Pétition\" disponible avec votre préconfiguration. Grâce à ce modèle créez en un clique une pétition que vous pouvez ensuite diffuser sur Internet (site Internet, blog, réseaux sociaux, emails, etc...). Les personnes extèrieures y ont accès, lorsqu'elles signent elles sont automatiquement ajoutées à vos contacts. Il n'y a qu'un seul champ demandé lors de la signature (voir \"Mon inscription\") mais vous pouvez en ajouter autant que vous le souhaitez. Notez que vous pouvez exporter la liste des signataires avec leurs nom, prénom, email et code postal dans la grille des participants. " ;
       "date", "20220630" ;
       "enddate", "20221231" ;
       "coord", "Le président de l'association" ;
       "moreinfo", "Cette pétition a été créée automatiquement lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.event-ag.name" eventAg
      ~name:(adlib "EntitySampleEventAgName" ~old:"entity.sample.event-ag.name" "Exemple d'AG dans RunOrg") [
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre assemblée générale.    1. Ce champ est également disponible avec le modèle des réunions    2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours    3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier    4. Etc." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") [
       "desc", "Pour répondre à ce sondage rendez-vous dans l'onglet \"Mon inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à l'association, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à l'association. Toutes les adhésions envoient automatiquement leurs membres vers ce groupe." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
  ])
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

  ])
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
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-structure.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationStructureName" ~old:"entity.sample.group-collaborative.federation-structure.name" "Structure fédérale") [
       "desc", "Groupe des salariés et des équipes de la structure fédérale" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-dtn.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationDtnName" ~old:"entity.sample.group-collaborative.federation-dtn.name" "Direction Technique Nationale") [
       "desc", "Groupe des membres de la DTN" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-comite.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationComiteName" ~old:"entity.sample.group-collaborative.federation-comite.name" "Comité directeur") [
       "desc", "Groupe des membres du comité directeur" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-clubs-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationClubsAssoName" ~old:"entity.sample.group-collaborative.federation-clubs-asso.name" "Clubs & associations affiliés") [
       "desc", "Groupes des clubs et associations affiliées à la fédération" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-presidents.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationPresidentsName" ~old:"entity.sample.group-collaborative.federation-presidents.name" "Présidents de clubs et d'asso affiliés") [
       "desc", "Groupe des présidents de clubs et d'associations affiliées" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
  ])
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

  ])
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
    initial "entity.sample.subscribtion-forever.name" subscriptionForever
      ~name:(adlib "EntitySampleSubscribtionForeverName" ~old:"entity.sample.subscribtion-forever.name" "Adhésion permanente") [
       "desc", "Cette adhésion permet de donnéer accès à RunOrg aux employés, profs, membres honoraires et autres intervenants de votre association. " ;
       "summary", "Accès salariés, professeurs et autre " ;
       "moreinfo", "Cette adhésion a été créée automatiquement lors de la création de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérants 2012-2013") [
       ] ;
    initial "entity.sample.group-footus.name" groupFootus
      ~name:(adlib "EntitySampleGroupFootusName" ~old:"entity.sample.group-footus.name" "Joueurs football américain") [
       "desc", "Groupe des Sportifs football américain, c'est dans ce groupe que se trouve le formulaire que les sportifs doivent renseigner pour s'inscrire au club. Ne pas supprimer ce groupe. Vous pouvez modifier les informations du formulaire dans \"options > champs spécifiques\"." ;
       "moreinfo", "Lorsque vous créez une nouvelle adhésion pour les sportifs, n'oubliez pas de la relier à ce groupe via \"inscription automatique\" depuis les options de ce groupe pour que les personnes inscritent à l'adhésions soient automatiquement ajoutées aux sportifs. Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg" ;
      ] ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") [
       "desc", "Groupe des responsables de l'association. Les administrateurs et les membres du bureau de l'association peuvent échanger en toute confidentialité dans ce groupe. Pour pouvoir accèder au contenu de ce groupe un administrateur doit inviter les personnes ou valider leur demande d'inscription." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la création de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-cheerleading.name" groupCheerleading
      ~name:(adlib "EntitySampleGroupCheerleadingName" ~old:"entity.sample.group-cheerleading.name" "Cheerleaders") [
       "desc", "Groupe des Cheerleaders, c'est dans ce groupe que se trouve le formulaire que les sportifs doivent renseigner pour s'inscrire au club. Ne pas supprimer ce groupe. Vous pouvez modifier les informations du formulaire dans \"options > champs spécifiques\"." ;
       "moreinfo", "Lorsque vous créez une nouvelle adhésion pour les sportifs, n'oubliez pas de la relier à ce groupe via \"inscription automatique\" depuis les options de ce groupe pour que les personnes inscritent à l'adhésions soient automatiquement ajoutées aux sportifs. Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg" ;
      ] ;
    initial "entity.sample.event-simple.name" eventSimple
      ~name:(adlib "EntitySampleEventSimpleName" ~old:"entity.sample.event-simple.name" "Exemple d'évènement dans RunOrg") [
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.event-ag.name" eventAg
      ~name:(adlib "EntitySampleEventAgName" ~old:"entity.sample.event-ag.name" "Exemple d'AG dans RunOrg") [
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre assemblée générale.    1. Ce champ est également disponible avec le modèle des réunions    2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours    3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier    4. Etc." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") [
       "desc", "Pour répondre à ce sondage rendez-vous dans l'onglet \"Mon inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à l'association, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.jobs-sport.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") [
       "desc", "Que ce soit des offres ou des demandes d'emplois saisonniers, plus long terme, liés à notre sport ou autre : c'est ici qu'on les partage !. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. " ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg." ;
       "summary", "Venez poster ici vos offres et vos demandes" ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à l'association. Toutes les adhésions envoient automatiquement leurs membres vers ce groupe." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
  ])
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

  ])
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
    initial "entity.sample.subscribtion-forever.name" subscriptionForever
      ~name:(adlib "EntitySampleSubscribtionForeverName" ~old:"entity.sample.subscribtion-forever.name" "Adhésion permanente") [
       "desc", "Cette adhésion permet de donnéer accès à RunOrg aux employés, profs, membres honoraires et autres intervenants de votre association. " ;
       "summary", "Accès salariés, professeurs et autre " ;
       "moreinfo", "Cette adhésion a été créée automatiquement lors de la création de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérants 2012-2013") [
       ] ;
    initial "entity.sample.group-judo-members.name" groupJudoMembers
      ~name:(adlib "EntitySampleGroupJudoMembersName" ~old:"entity.sample.group-judo-members.name" "Sportifs judo et jujitsu") [
       "desc", "Groupe des Sportifs judo et jujitsu, c'est dans ce groupe que se trouve le formulaire que les sportifs doivent renseigner pour s'inscrire au club. Ne pas supprimer ce groupe. Vous pouvez modifier les informations du formulaire dans \"options > champs spécifiques\". " ;
       "moreinfo", "Lorsque vous créez une nouvelle adhésion pour les sportifs, n'oubliez pas de la relier à ce groupe via \"inscription automatique\" depuis les options de ce groupe pour que les personnes inscritent à l'adhésions soient automatiquement ajoutées aux sportifs. Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") [
       "desc", "Groupe des responsables de l'association. Les administrateurs et les membres du bureau de l'association peuvent échanger en toute confidentialité dans ce groupe. Pour pouvoir accèder au contenu de ce groupe un administrateur doit inviter les personnes ou valider leur demande d'inscription." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la création de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.event-simple.name" eventSimple
      ~name:(adlib "EntitySampleEventSimpleName" ~old:"entity.sample.event-simple.name" "Exemple d'évènement dans RunOrg") [
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.event-ag.name" eventAg
      ~name:(adlib "EntitySampleEventAgName" ~old:"entity.sample.event-ag.name" "Exemple d'AG dans RunOrg") [
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre assemblée générale.    1. Ce champ est également disponible avec le modèle des réunions    2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours    3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier    4. Etc." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") [
       "desc", "Pour répondre à ce sondage rendez-vous dans l'onglet \"Mon inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à l'association, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.jobs-sport.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") [
       "desc", "Que ce soit des offres ou des demandes d'emplois saisonniers, plus long terme, liés à notre sport ou autre : c'est ici qu'on les partage !. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. " ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg." ;
       "summary", "Venez poster ici vos offres et vos demandes" ;
      ] ;
    initial "entity.sample.sport.group-petitssamourais.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPetitssamouraisName" ~old:"entity.sample.sport.group-petitssamourais.name" "Petits samouraïs") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-poussinnets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinnetsName" ~old:"entity.sample.sport.group-poussinnets.name" "Poussinets") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à l'association. Toutes les adhésions envoient automatiquement leurs membres vers ce groupe." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
  ])
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

  ])
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
  ])
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
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2011-2012") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.group-collaborative.mda-resp-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespAssoName" ~old:"entity.sample.group-collaborative.mda-resp-asso.name" "Responsables d'associations") [
       "desc", "Groupe des responsables d'associations" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.mda-resp-commune.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespCommuneName" ~old:"entity.sample.group-collaborative.mda-resp-commune.name" "Responsables municipaux") [
       "desc", "Groupe des responsables municipaux" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.mda-member-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaMemberAssoName" ~old:"entity.sample.group-collaborative.mda-member-asso.name" "Membres d'associations") [
       "desc", "Groupe des membres d'associations" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
  ])
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
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2011-2012") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.group-collaborative.mda-resp-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespAssoName" ~old:"entity.sample.group-collaborative.mda-resp-asso.name" "Responsables d'associations") [
       "desc", "Groupe des responsables d'associations" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.mda-resp-commune.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaRespCommuneName" ~old:"entity.sample.group-collaborative.mda-resp-commune.name" "Responsables municipaux") [
       "desc", "Groupe des responsables municipaux" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.mda-member-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeMdaMemberAssoName" ~old:"entity.sample.group-collaborative.mda-member-asso.name" "Membres d'associations") [
       "desc", "Groupe des membres d'associations" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
  ])
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
    initial "entity.sample.subscribtion-forever.name" subscriptionForever
      ~name:(adlib "EntitySampleSubscribtionForeverName" ~old:"entity.sample.subscribtion-forever.name" "Adhésion permanente") [
       "desc", "Cette adhésion permet de donnéer accès à RunOrg aux employés, profs, membres honoraires et autres intervenants de votre association. " ;
       "summary", "Accès salariés, professeurs et autre " ;
       "moreinfo", "Cette adhésion a été créée automatiquement lors de la création de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérants 2012-2013") [
       ] ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") [
       "desc", "Groupe des responsables de l'association. Les administrateurs et les membres du bureau de l'association peuvent échanger en toute confidentialité dans ce groupe. Pour pouvoir accèder au contenu de ce groupe un administrateur doit inviter les personnes ou valider leur demande d'inscription." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la création de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.event-simple.name" eventSimple
      ~name:(adlib "EntitySampleEventSimpleName" ~old:"entity.sample.event-simple.name" "Exemple d'évènement dans RunOrg") [
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.event-ag.name" eventAg
      ~name:(adlib "EntitySampleEventAgName" ~old:"entity.sample.event-ag.name" "Exemple d'AG dans RunOrg") [
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre assemblée générale.    1. Ce champ est également disponible avec le modèle des réunions    2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours    3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier    4. Etc." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") [
       "desc", "Pour répondre à ce sondage rendez-vous dans l'onglet \"Mon inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.forum-public.jobs-sport.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") [
       "desc", "Que ce soit des offres ou des demandes d'emplois saisonniers, plus long terme, liés à notre sport ou autre : c'est ici qu'on les partage !. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. " ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg." ;
       "summary", "Venez poster ici vos offres et vos demandes" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à l'association, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à l'association. Toutes les adhésions envoient automatiquement leurs membres vers ce groupe." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
  ])
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

  ])
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
  ])
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
  ])
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
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérants 2012-2013") [
       ] ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") [
       "desc", "Groupe des responsables de l'association. Les administrateurs et les membres du bureau de l'association peuvent échanger en toute confidentialité dans ce groupe. Pour pouvoir accèder au contenu de ce groupe un administrateur doit inviter les personnes ou valider leur demande d'inscription." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la création de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.event-ag.name" eventAg
      ~name:(adlib "EntitySampleEventAgName" ~old:"entity.sample.event-ag.name" "Exemple d'AG dans RunOrg") [
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre assemblée générale.    1. Ce champ est également disponible avec le modèle des réunions    2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours    3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier    4. Etc." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") [
       "desc", "Pour répondre à ce sondage rendez-vous dans l'onglet \"Mon inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à l'association, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
  ])
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
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2011-2012") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-structure.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationStructureName" ~old:"entity.sample.group-collaborative.federation-structure.name" "Structure fédérale") [
       "desc", "Groupe des salariés et des équipes de la structure fédérale" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-dtn.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationDtnName" ~old:"entity.sample.group-collaborative.federation-dtn.name" "Direction Technique Nationale") [
       "desc", "Groupe des membres de la DTN" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-comite.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationComiteName" ~old:"entity.sample.group-collaborative.federation-comite.name" "Comité directeur") [
       "desc", "Groupe des membres du comité directeur" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-clubs-asso.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationClubsAssoName" ~old:"entity.sample.group-collaborative.federation-clubs-asso.name" "Clubs & associations affiliés") [
       "desc", "Groupes des clubs et associations affiliées à la fédération" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-collaborative.federation-presidents.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeFederationPresidentsName" ~old:"entity.sample.group-collaborative.federation-presidents.name" "Présidents de clubs et d'asso affiliés") [
       "desc", "Groupe des présidents de clubs et d'associations affiliées" ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise à disposition de votre espace RunOrg." ;
      ] ;
  ])
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
    initial "entity.sample.sub-runorg.name" subscriptionForever
      ~name:(adlib "EntitySampleSubRunorgName" ~old:"entity.sample.sub-runorg.name" "Adhérants 2012-2013") [
       ] ;
    initial "entity.sample.group-collaborative.office.name" groupCollaborative
      ~name:(adlib "EntitySampleGroupCollaborativeOfficeName" ~old:"entity.sample.group-collaborative.office.name" "Bureau et administrateurs de l'association") [
       "desc", "Groupe des responsables de l'association. Les administrateurs et les membres du bureau de l'association peuvent échanger en toute confidentialité dans ce groupe. Pour pouvoir accèder au contenu de ce groupe un administrateur doit inviter les personnes ou valider leur demande d'inscription." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la création de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.event-simple.name" eventSimple
      ~name:(adlib "EntitySampleEventSimpleName" ~old:"entity.sample.event-simple.name" "Exemple d'évènement dans RunOrg") [
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.event-ag.name" eventAg
      ~name:(adlib "EntitySampleEventAgName" ~old:"entity.sample.event-ag.name" "Exemple d'AG dans RunOrg") [
       "agenda", "Grâce à ce champ, vous pouvez communiquer à tous vos membres l'ordre du jour de votre assemblée générale.    1. Ce champ est également disponible avec le modèle des réunions    2. Vous pouvez avant la réunion exporter au format excel la liste des participants ainsi que tous leurs retours    3. Mettez ce champ à jour à tout moment : seuls les administrateurs peuvent le modifier    4. Etc." ;
      ] ;
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2012-2013") [
       "desc", "Pour répondre à ce sondage rendez-vous dans l'onglet \"Mon inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20221231" ;
      ] ;
    initial "entity.sample.forum-public.jobs-sport.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicJobsSportName" ~old:"entity.sample.forum-public.jobs-sport.name" "Offres et demandes d'emplois") [
       "desc", "Que ce soit des offres ou des demandes d'emplois saisonniers, plus long terme, liés à notre sport ou autre : c'est ici qu'on les partage !. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. " ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg." ;
       "summary", "Venez poster ici vos offres et vos demandes" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à l'association, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.sport.group-poussins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupPoussinsName" ~old:"entity.sample.sport.group-poussins.name" "Poussins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-benjamins.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupBenjaminsName" ~old:"entity.sample.sport.group-benjamins.name" "Benjamins") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-minimes.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupMinimesName" ~old:"entity.sample.sport.group-minimes.name" "Minimes") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-cadets.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupCadetsName" ~old:"entity.sample.sport.group-cadets.name" "Cadets") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-juniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupJuniorsName" ~old:"entity.sample.sport.group-juniors.name" "Juniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-seniors.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupSeniorsName" ~old:"entity.sample.sport.group-seniors.name" "Séniors") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.sport.group-veterans.name" groupSimple
      ~name:(adlib "EntitySampleSportGroupVeteransName" ~old:"entity.sample.sport.group-veterans.name" "Vétérans") [
       "desc", "Groupe créé pour que vous y rajoutiez les sportifs correspondants à la tranche d'age." ;
       "moreinfo", "Ce groupe a été créé automatiquement lors de la mise en place de votre espace RunOrg." ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à l'association. Toutes les adhésions envoient automatiquement leurs membres vers ce groupe." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
  ])
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
  Template.([
  ])
;;

(* ========================================================================== *)

let stub = vertical "Stub"
  ~old:"v:stub"
  ~name:"Profil uniquement"
  ~archive:true
  Template.([
    initial "entity.sample.poll-yearly.name" pollYearly
      ~name:(adlib "EntitySamplePollYearlyName" ~old:"entity.sample.poll-yearly.name" "Bilan de l'année 2011-2012") [
       "desc", "Pour répondre à ce sondage cliquez sur \"inscription\". Vous pouvez ainsi utiliser immédiatement ce sondage que nous avons créé pour vous sous la forme d'un modèle réutilisable. Il vous est possible d'inviter vos membres à répondre à ce sondage en les ajoutant dans la liste des invités. " ;
       "summary", "Exemple de sondage" ;
       "moreinfo", "Ce sondage a été créé automatiquement lors de la mise en place de votre espace RunOrg. Cliquez sur créer un sondage pour voir les autres modèles disponibles." ;
       "enddate", "20121231" ;
      ] ;
    initial "entity.sample.forum-public.classified.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicClassifiedName" ~old:"entity.sample.forum-public.classified.name" "Petites annonces") [
       "desc", "Profitez de ce forum pour poster vos diverses petites annonces. Pour répondre aux annonces : cliquez simplement sur répondre pour laisser votre message. Si vous avez des photos à poster en complément de vos annonces : un album est à votre disposition." ;
       "summary", "Venez poster ici vos petites annonces" ;
       "morinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.forum-public.user-support.name" forumPublic
      ~name:(adlib "EntitySampleForumPublicUserSupportName" ~old:"entity.sample.forum-public.user-support.name" "Utilisation de RunOrg") [
       "desc", "Ce forum a pour but de partager les bons conseils sur l'utilisation de RunOrg, et de répondre aux questions que vous pourriez vous poser. Ce forum d'entraide est interne à la copro, les équipes de RunOrg n'y ont pas accès. " ;
       "summary", "Aide pour utiliser RunOrg" ;
       "moreinfo", "Ce forum a été créé pour exemple lors de la mise en place de votre espace RunOrg. " ;
      ] ;
    initial "entity.sample.group-simple.allmembers.name" groupSimple
      ~name:(adlib "EntitySampleGroupSimpleAllmembersName" ~old:"entity.sample.group-simple.allmembers.name" "Tous les membres") [
       "desc", "Il ne faut pas supprimer ce groupe. Ce groupe a pour objectif de regrouper toutes les personnes à qui vous donnez un accès à votre espace." ;
       "summary", "Tous les membres" ;
       "moreinfo", "Quand vous voulez communiquer vers tout vos membres ou tous les inviter à un évènement ou autre, c'est ce groupe que vous choississez. Cliquez sur \"créer un groupe\" pour voir les autres modèles disponibles." ;
      ] ;
  ])
  Template.([
  ])
;;

(* ========================================================================== *)

let students = vertical "Students"
  ~old:"v:students"
  ~name:"Association étudiante"
  Template.([
  ])
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
              (adlib "VerticalCompanyTrainingName" "Centres de formation")
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
