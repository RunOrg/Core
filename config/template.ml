(* © 2012 RunOrg *)
open Common

(* ========================================================================== *)

let admin = template "Admin"
  ~old:"admin"
  ~kind:`Group
  ~name:"Groupe des Administrateurs RunOrg"
  ~desc:"Groupe des administrateurs RunOrg. Les personnes inscrites dans ce groupe ont toute la visibilité et tous les droits dans l'espace Runorg de l'organisation. Ce groupe ne doit pas être supprimé."
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let albumSimple = template "AlbumSimple"
  ~old:"album-simple"
  ~kind:`Album
  ~name:"Album Photo Simple"
  ~desc:"Contribution libre"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let course12sessions = template "Course12sessions"
  ~old:"course-12sessions"
  ~kind:`Course
  ~name:"Cours 12 séances"
  ~desc:"Ce cours permet de suivre par date les activités réalisées lors de 12 séances. Peut être renseigné par l'élève ou le prof"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          ~label:(adlib "Info_Item_Moreinfo" "Informations complémentaires")
          [
            infoField "moreinfo" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Prerequisite" "Pré-requis")
          [
            infoField "prerequisite" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Curriculum" "Programme du cours")
          [
            infoField "curriculum" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          ~label:(adlib "Info_Item_Coord" "Formateur")
          [
            infoField "teacher" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
            infoField "date" `Date ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let course12sessionsFitness = template "Course12sessionsFitness"
  ~old:"course-12sessions-fitness"
  ~kind:`Course
  ~name:"Cours 12 séances fitness"
  ~desc:"Ce cours permet de suivre par date les activités réalisées lors de 12 séances et de réccupérer les retours des élèves. Peut être renseigné par l'élève et/ou le prof"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          ~label:(adlib "Info_Item_Moreinfo" "Informations complémentaires")
          [
            infoField "moreinfo" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Prerequisite" "Pré-requis")
          [
            infoField "prerequisite" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Curriculum" "Programme du cours")
          [
            infoField "curriculum" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          ~label:(adlib "Info_Item_Coord" "Formateur")
          [
            infoField "teacher" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
            infoField "date" `Date ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let courseSimple = template "CourseSimple"
  ~old:"course-simple"
  ~kind:`Course
  ~name:"Cours Simple"
  ~desc:"Ouvert à inscription, organisé à une date fixe."
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          ~label:(adlib "Info_Item_Moreinfo" "Informations complémentaires")
          [
            infoField "moreinfo" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Prerequisite" "Pré-requis")
          [
            infoField "prerequisite" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Curriculum" "Programme du cours")
          [
            infoField "curriculum" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          ~label:(adlib "Info_Item_Coord" "Formateur")
          [
            infoField "teacher" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
            infoField "date" `Date ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let courseStage = template "CourseStage"
  ~old:"course-stage"
  ~kind:`Course
  ~name:"Stage"
  ~desc:"organisez un stage sur plusieurs jours"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          ~label:(adlib "Info_Item_Moreinfo" "Informations complémentaires")
          [
            infoField "moreinfo" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Prerequisite" "Pré-requis")
          [
            infoField "prerequisite" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Curriculum" "Programme du cours")
          [
            infoField "curriculum" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          ~label:(adlib "Info_Item_Coord" "Formateur")
          [
            infoField "teacher" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_MealAccomodation" "Repas et hébergement")
          [
            infoField "meal-accomodation" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
            infoField "date" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let courseTraining = template "CourseTraining"
  ~old:"course-training"
  ~kind:`Course
  ~name:"Formation"
  ~desc:"Organisez une formation"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          ~label:(adlib "Info_Item_Moreinfo" "Informations complémentaires")
          [
            infoField "moreinfo" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Prerequisite" "Pré-requis")
          [
            infoField "prerequisite" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Curriculum" "Programme du cours")
          [
            infoField "curriculum" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          ~label:(adlib "Info_Item_Coord" "Formateur")
          [
            infoField "teacher" `Text ;
            infoField "meal-accomodation" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_MealAccomodation" "Repas et hébergement")
          [
            infoField "meal-accomodation" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
            infoField "date" `Date ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventAfterwork = template "EventAfterwork"
  ~old:"event-afterwork"
  ~kind:`Event
  ~name:"Afterwork"
  ~desc:"Organisez un afterwork dont vous validez les inscriptions. Par défaut il est visible par vos contacts (peut être modifié dans les options)"
  ~page:[
    infoSection
      (adlib "Info_Section_Afterwork" "Afterwork")
      [
        infoItem
          ~label:(adlib "Info_Item_Buffet" "Buffet")
          [
            infoField "buffet" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SpecialOffer" "Offre spéciale")
          [
            infoField "special-offer" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SpecialOffer" "Offre spéciale")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Price" "Prix")
      [
        infoItem
          ~label:(adlib "Info_Item_PriceInfo" "Infos prix")
          [
            infoField "price-info" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ticketing" "Billeterie")
          [
            infoField "ticketing" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_InvitationsDiscounts" "Invitations & réductions")
          [
            infoField "invitations-discounts" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Ambiance" "Ambiance")
      [
        infoItem
          ~label:(adlib "Info_Item_Theme" "Thème")
          [
            infoField "theme" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ambiance" "Ambiance")
          [
            infoField "ambiance" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_KindOfMusic" "Type de musique")
          [
            infoField "kind-of-music" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Djs" "DJs")
          [
            infoField "djs" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_DressCode" "Dress code")
          [
            infoField "dress-code" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SponsorsPartners" "Sponsors & partenaires")
          [
            infoField "sponsors-partners" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_ContactInfo" "Contact")
          [
            infoField "contact-info" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_ReservationContact" "Réservations")
          [
            infoField "reservation-contact" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Cloakroom" "Vestiaire")
          [
            infoField "cloakroom" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_TransportationService" "Bus/navette")
          [
            infoField "transportation-service" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventAfterworkAuto = template "EventAfterworkAuto"
  ~old:"event-afterwork-auto"
  ~kind:`Event
  ~name:"Aferwork  inscriptions automatiques"
  ~desc:"Organisez un afterwork avec inscriptions automatiques. Par défaut il est visible par vos contacts (peut être modifié dans les options)"
  ~page:[
    infoSection
      (adlib "Info_Section_Afterwork" "Afterwork")
      [
        infoItem
          ~label:(adlib "Info_Item_Buffet" "Buffet")
          [
            infoField "buffet" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SpecialOffer" "Offre spéciale")
          [
            infoField "special-offer" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SpecialOffer" "Offre spéciale")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Price" "Prix")
      [
        infoItem
          ~label:(adlib "Info_Item_PriceInfo" "Infos prix")
          [
            infoField "price-info" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ticketing" "Billeterie")
          [
            infoField "ticketing" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_InvitationsDiscounts" "Invitations & réductions")
          [
            infoField "invitations-discounts" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Ambiance" "Ambiance")
      [
        infoItem
          ~label:(adlib "Info_Item_Theme" "Thème")
          [
            infoField "theme" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ambiance" "Ambiance")
          [
            infoField "ambiance" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_KindOfMusic" "Type de musique")
          [
            infoField "kind-of-music" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Djs" "DJs")
          [
            infoField "djs" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_DressCode" "Dress code")
          [
            infoField "dress-code" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SponsorsPartners" "Sponsors & partenaires")
          [
            infoField "sponsors-partners" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_ContactInfo" "Contact")
          [
            infoField "contact-info" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_ReservationContact" "Réservations")
          [
            infoField "reservation-contact" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Cloakroom" "Vestiaire")
          [
            infoField "cloakroom" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_TransportationService" "Bus/navette")
          [
            infoField "transportation-service" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventAg = template "EventAg"
  ~old:"event-ag"
  ~kind:`Event
  ~name:"Assemblée Générale"
  ~desc:"Organisation de l'AG de l'association"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventCampaignAction = template "EventCampaignAction"
  ~old:"event-campaign-action"
  ~kind:`Event
  ~name:"Opération militante"
  ~desc:"Organisez une opération militante et reccueillez les CR de cette action"
  ~page:[
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_What" "Quoi ?")
      [
        infoItem
          [
            infoField "action-type" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_ActionDetails" "Détails techniques de l'opération")
          [
            infoField "action-details" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "action-zone" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventCampaignMeeting = template "EventCampaignMeeting"
  ~old:"event-campaign-meeting"
  ~kind:`Event
  ~name:"Réunion électorale publique"
  ~desc:"Organisez une réunion électorale et reccueillez les thèmes attendus par les participants"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventClubbing = template "EventClubbing"
  ~old:"event-clubbing"
  ~kind:`Event
  ~name:"Soirée"
  ~desc:"Organisez une soirée dont vous validez les inscriptions. Par défaut elle est visible par vos contacts (peut être modifié dans les options)"
  ~page:[
    infoSection
      (adlib "Info_Section_Price" "Prix")
      [
        infoItem
          ~label:(adlib "Info_Item_PriceInfo" "Infos prix")
          [
            infoField "price-info" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ticketing" "Billeterie")
          [
            infoField "ticketing" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_InvitationsDiscounts" "Invitations & réductions")
          [
            infoField "invitations-discounts" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Ambiance" "Ambiance")
      [
        infoItem
          ~label:(adlib "Info_Item_Theme" "Thème")
          [
            infoField "theme" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ambiance" "Ambiance")
          [
            infoField "ambiance" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_KindOfMusic" "Type de musique")
          [
            infoField "kind-of-music" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Djs" "DJs")
          [
            infoField "djs" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_DressCode" "Dress code")
          [
            infoField "dress-code" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SponsorsPartners" "Sponsors & partenaires")
          [
            infoField "sponsors-partners" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_ContactInfo" "Contact")
          [
            infoField "contact-info" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_ReservationContact" "Réservations")
          [
            infoField "reservation-contact" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Cloakroom" "Vestiaire")
          [
            infoField "cloakroom" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_TransportationService" "Bus/navette")
          [
            infoField "transportation-service" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventClubbingAuto = template "EventClubbingAuto"
  ~old:"event-clubbing-auto"
  ~kind:`Event
  ~name:"Soirée inscriptions automatiques"
  ~desc:"Organisez une soirée avec inscriptions automatiques. Par défaut elle est visible par vos contacts (peut être modifié dans les options)"
  ~page:[
    infoSection
      (adlib "Info_Section_Price" "Prix")
      [
        infoItem
          ~label:(adlib "Info_Item_PriceInfo" "Infos prix")
          [
            infoField "price-info" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ticketing" "Billeterie")
          [
            infoField "ticketing" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_InvitationsDiscounts" "Invitations & réductions")
          [
            infoField "invitations-discounts" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Ambiance" "Ambiance")
      [
        infoItem
          ~label:(adlib "Info_Item_Theme" "Thème")
          [
            infoField "theme" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Ambiance" "Ambiance")
          [
            infoField "ambiance" `LongText ;
          ];
        infoItem
          ~label:(adlib "Info_Item_KindOfMusic" "Type de musique")
          [
            infoField "kind-of-music" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Djs" "DJs")
          [
            infoField "djs" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_DressCode" "Dress code")
          [
            infoField "dress-code" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_SponsorsPartners" "Sponsors & partenaires")
          [
            infoField "sponsors-partners" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_ContactInfo" "Contact")
          [
            infoField "contact-info" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_ReservationContact" "Réservations")
          [
            infoField "reservation-contact" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Cloakroom" "Vestiaire")
          [
            infoField "cloakroom" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_TransportationService" "Bus/navette")
          [
            infoField "transportation-service" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventComiteEnt = template "EventComiteEnt"
  ~old:"event-comite-ent"
  ~kind:`Event
  ~name:"Comité d'entreprise"
  ~desc:"Organisez un comité d'entreprise"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventCoproMeeting = template "EventCoproMeeting"
  ~old:"event-copro-meeting"
  ~kind:`Event
  ~name:"Conseil syndical"
  ~desc:"Organisez un conseil syndical"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventImproSimple = template "EventImproSimple"
  ~old:"event-impro-simple"
  ~kind:`Event
  ~name:"Match d'improvisation (organisation)"
  ~desc:"Organisation interne d'un match contre une autre équipe"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_PlayerTime" "Heure d'arrivée")
          [
            infoField "player-time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Mc" "MC")
          [
            infoField "mc" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Referee" "Arbitre")
          [
            infoField "referee" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          [
            infoField "" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Against" "Contre Qui ?")
      [
        infoItem
          [
            infoField "against-team" `Text ;
          ];
        infoItem
          [
            infoField "against-team-url" `Url ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventImproSpectacle = template "EventImproSpectacle"
  ~old:"event-impro-spectacle"
  ~kind:`Event
  ~name:"Spectacle d'improvisation (organisation)"
  ~desc:"Organisation interne d'un spectacle d'improvisation"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_PlayerTime" "Heure d'arrivée")
          [
            infoField "player-time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Mc" "MC")
          [
            infoField "mc" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          [
            infoField "" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventMeeting = template "EventMeeting"
  ~old:"event-meeting"
  ~kind:`Event
  ~name:"Réunion"
  ~desc:"Organisation d'une réunion"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventPetition = template "EventPetition"
  ~old:"event-petition"
  ~kind:`Event
  ~name:"Pétition"
  ~desc:"Organisez une pétition et personnalisez les informations demandées aux signataires. Les pétitions sont accessibles à vos contacts"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Url" "Site web")
          [
            infoField "url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Validity" "Validité")
      [
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
            infoField "date" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Validité")
          [
            infoField "enddate" `Date ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventPublicComity = template "EventPublicComity"
  ~old:"event-public-comity"
  ~kind:`Event
  ~name:"Conseil municipal"
  ~desc:"Organisez un conseil municipal"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventSimple = template "EventSimple"
  ~old:"event-simple"
  ~kind:`Event
  ~name:"Evènement Simple"
  ~desc:"Une date, un lieu, une liste d'invités. Validation manuelle des inscriptions pour les non-invités."
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let eventSimpleAuto = template "EventSimpleAuto"
  ~old:"event-simple-auto"
  ~kind:`Event
  ~name:"Evènement Simple inscriptions automatiques"
  ~desc:"Une date, un lieu, une liste d'invités. Validation automatique des inscriptions pour les non-invités."
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Coord" "Coordinateur")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Where" "Où ?")
      [
        infoItem
          [
            infoField "location" `Text ;
          ];
        infoItem
          [
            infoField "address" `Address ;
          ];
        infoItem
          [
            infoField "location-url" `Url ;
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "Quand ?")
      [
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Coordinateur")
          [
            infoField "date" `Date ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Time" "Heure de début")
          [
            infoField "time" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Endtime" "Heure de fin")
          [
            infoField "endtime" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let forumPublic = template "ForumPublic"
  ~old:"forum-public"
  ~kind:`Forum
  ~name:"Forum Public"
  ~desc:"Participation libre et sans inscription"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupCheerleading = template "GroupCheerleading"
  ~old:"group-cheerleading"
  ~kind:`Group
  ~name:"Sportifs cheerleaders"
  ~desc:"Grâce à ce groupe vous disposez de toutes les informations demandées à des sportifs dans le cadre du cheerleading"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupCollaborative = template "GroupCollaborative"
  ~old:"group-collaborative"
  ~kind:`Group
  ~name:"Groupe collaboratif"
  ~desc:"Ce type de groupe peut être utilisé comme un espace collaboratif. Il comporte tous les objets collaboratifs (mur, albums, documents, etc.)"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupCollaborativeAuto = template "GroupCollaborativeAuto"
  ~old:"group-collaborative-auto"
  ~kind:`Group
  ~name:"Groupe collaboratif inscriptions automatiques"
  ~desc:"Groupe collaboratif avec validation automatique des inscriptions pour les non-invités"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupContact = template "GroupContact"
  ~old:"group-contact"
  ~kind:`Group
  ~name:"Contacts"
  ~desc:"Groupe en accès public et validé automatiquement de personnes n'ayant pas accès à votre espace, mais qui peuvent être contactées via RunOrg"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupCoproEmployes = template "GroupCoproEmployes"
  ~old:"group-copro-employes"
  ~kind:`Group
  ~name:"Gardiens / employés"
  ~desc:"Groupe collabroratif dédié aux gardiens et salariés"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupCoproLodger = template "GroupCoproLodger"
  ~old:"group-copro-lodger"
  ~kind:`Group
  ~name:"Locataires"
  ~desc:"Groupe collabroratif dédié aux locataires"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupCoproManager = template "GroupCoproManager"
  ~old:"group-copro-manager"
  ~kind:`Group
  ~name:"Gestionnaires"
  ~desc:"Groupe collabroratif dédié aux gestionnaires"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupCorproOwner = template "GroupCorproOwner"
  ~old:"group-corpro-owner"
  ~kind:`Group
  ~name:"Propriétaires"
  ~desc:"Groupe collaboratif dédié aux propriétaires"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupFitnessMembers = template "GroupFitnessMembers"
  ~old:"group-fitness-members"
  ~kind:`Group
  ~name:"Sportifs fitness"
  ~desc:"Grâce à ce groupe vous disposez de toutes les informations demandées à des sportifs dans le cadre d'une salle de sport ou d'un coaching sportif"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupFootus = template "GroupFootus"
  ~old:"group-footus"
  ~kind:`Group
  ~name:"Sportifs football américain"
  ~desc:"Grâce à ce groupe vous disposez de toutes les informations demandées à des sportifs dans le cadre du football américain"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupJudoMembers = template "GroupJudoMembers"
  ~old:"group-judo-members"
  ~kind:`Group
  ~name:"Sportifs judo et jujitsu"
  ~desc:"Grâce à ce groupe vous disposez de toutes les informations demandées à des sportifs dans le cadre de la pratique du judo et du jujitsu"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupRespo = template "GroupRespo"
  ~old:"group-respo"
  ~kind:`Group
  ~name:"Responsables"
  ~desc:"Un groupe de responsables"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupSimple = template "GroupSimple"
  ~old:"group-simple"
  ~kind:`Group
  ~name:"Groupe simple"
  ~desc:"Type de groupe dédié à la gestion des membres. Il comporte une simple liste de membre aucun objet collaboratif (mur, albums, documents, etc.)"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let groupTest = template "GroupTest"
  ~old:"group-test"
  ~kind:`Group
  ~name:"Groupe Test"
  ~desc:"Un groupe pour tester les préconfigs"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let pollSimple = template "PollSimple"
  ~old:"poll-simple"
  ~kind:`Poll
  ~name:"Sondage Simple"
  ~desc:"Participation libre"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let pollYearly = template "PollYearly"
  ~old:"poll-yearly"
  ~kind:`Poll
  ~name:"Bilan de l'année écoulée"
  ~desc:"Proposition de questions que vous pouvez poser en fin d'année à vos adhérents pour avoir leurs retours"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let subscriptionAuto = template "SubscriptionAuto"
  ~old:"subscription-auto"
  ~kind:`Subscription
  ~name:"Adhésion Automatique"
  ~desc:"Sans validation par un responsable"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let subscriptionDatetodate = template "SubscriptionDatetodate"
  ~old:"subscription-datetodate"
  ~kind:`Subscription
  ~name:"Adhésion date à date (annuelle, semestrielle, autre)"
  ~desc:"Adhésion pour laquelle vous définissez une date de début et de fin de validité"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
            infoField "moreinfo" `Text ;
            infoField "moreinfo" `Text ;
            infoField "moreinfo" `Text ;
            infoField "moreinfo" `LongText ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "{! NON TRADUIT !}")
      [
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Validity" "Validité")
      [
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
            infoField "date" `Date ;
            infoField "date" `Date ;
            infoField "date" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let subscriptionDatetodateAuto = template "SubscriptionDatetodateAuto"
  ~old:"subscription-datetodate-auto"
  ~kind:`Subscription
  ~name:"Adhésion date à date automatique"
  ~desc:"Aucune validation par un responsable n’est nécessaire pour qu’un membre adhère. Adhésion avec une date de début et de fin de validité"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
            infoField "moreinfo" `Text ;
            infoField "moreinfo" `LongText ;
          ];
        infoItem
          [
          ];
        infoItem
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_When" "{! NON TRADUIT !}")
      [
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
      ];
    infoSection
      (adlib "Info_Section_Validity" "Validité")
      [
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
            infoField "date" `Date ;
            infoField "date" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
            infoField "enddate" `Date ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Date" "Date")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let subscriptionForever = template "SubscriptionForever"
  ~old:"subscription-forever"
  ~kind:`Subscription
  ~name:"Adhésion Permanente"
  ~desc:"Adhésion sans date de fin de validité"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let subscriptionForeverAuto = template "SubscriptionForeverAuto"
  ~old:"subscription-forever-auto"
  ~kind:`Subscription
  ~name:"Adhésion permanente automatique"
  ~desc:"Aucune validation par un responsable n’est nécessaire pour qu’un membre adhère. Adhésion sans date de fin de validité"
  ~page:[
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let subscriptionSemester = template "SubscriptionSemester"
  ~old:"subscription-semester"
  ~kind:`Subscription
  ~name:"Adhésion Semestrielle"
  ~desc:"Dure six mois, de date à date"
  ~page:[
    infoSection
      (adlib "Info_Section_When" "{! NON TRADUIT !}")
      [
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

(* ========================================================================== *)

let subscriptionYear = template "SubscriptionYear"
  ~old:"subscription-year"
  ~kind:`Subscription
  ~name:"Adhésion Annuelle"
  ~desc:"Dure un an, de date à date"
  ~page:[
    infoSection
      (adlib "Info_Section_When" "{! NON TRADUIT !}")
      [
        infoItem
          ~label:(adlib "Info_Item_Date" "Date de début")
          [
          ];
        infoItem
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          [
            infoField "moreinfo" `Text ;
          ];
      ];
  ]
  ()

