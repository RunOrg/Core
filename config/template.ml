(* © 2012 RunOrg *)
open Common

(* ========================================================================== *)

let admin = template "Admin"
  ~old:"admin"
  ~kind:`Group
  ~name:"Groupe des Administrateurs RunOrg"
  ~desc:"Groupe des administrateurs RunOrg. Les personnes inscrites dans ce groupe ont toute la visibilité et tous les droits dans l'espace Runorg de l'organisation. Ce groupe ne doit pas être supprimé."
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`No)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"date-session1" ~label:(adlib "JoinFormDateSession1" "Date séance 1") `Date ;
    join ~name:"comment-session1" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session2" ~label:(adlib "JoinFormDateSession2" "Date séance 2") `Date ;
    join ~name:"comment-session2" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session3" ~label:(adlib "JoinFormDateSession3" "Date séance 3") `Date ;
    join ~name:"comment-session3" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session4" ~label:(adlib "JoinFormDateSession4" "Date séance 4") `Date ;
    join ~name:"comment-session4" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session5" ~label:(adlib "JoinFormDateSession5" "Date séance 5") `Date ;
    join ~name:"comment-session5" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session6" ~label:(adlib "JoinFormDateSession6" "Date séance 6") `Date ;
    join ~name:"comment-session6" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session7" ~label:(adlib "JoinFormDateSession7" "Date séance 7") `Date ;
    join ~name:"comment-session7" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session8" ~label:(adlib "JoinFormDateSession8" "Date séance 8") `Date ;
    join ~name:"comment-session8" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session9" ~label:(adlib "JoinFormDateSession9" "Date séance 9") `Date ;
    join ~name:"comment-session9" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session10" ~label:(adlib "JoinFormDateSession10" "Date séance 10") `Date ;
    join ~name:"comment-session10" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session11" ~label:(adlib "JoinFormDateSession11" "Date séance 11") `Date ;
    join ~name:"comment-session11" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"date-session12" ~label:(adlib "JoinFormDateSession12" "Date séance 12") `Date ;
    join ~name:"comment-session12" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"feedback-session1" ~label:(adlib "JoinFormFeedbackSession1" "Feedback séance 1") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session1" ~label:(adlib "JoinFormRefSession1" "Ref séance 1") `LongText ;
    join ~name:"date-session1" ~label:(adlib "JoinFormDateSession1" "Date séance 1") `Date ;
    join ~name:"comment-session1" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session2" ~label:(adlib "JoinFormFeedbackSession2" "Feedback séance 2") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session2" ~label:(adlib "JoinFormRefSession2" "Ref séance 2") `LongText ;
    join ~name:"date-session2" ~label:(adlib "JoinFormDateSession2" "Date séance 2") `Date ;
    join ~name:"comment-session2" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session3" ~label:(adlib "JoinFormFeedbackSession3" "Feedback séance 3") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session3" ~label:(adlib "JoinFormRefSession3" "Ref séance 3") `LongText ;
    join ~name:"date-session3" ~label:(adlib "JoinFormDateSession3" "Date séance 3") `Date ;
    join ~name:"comment-session3" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session4" ~label:(adlib "JoinFormFeedbackSession4" "Feedback séance 4") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session4" ~label:(adlib "JoinFormRefSession4" "Ref séance 4") `LongText ;
    join ~name:"date-session4" ~label:(adlib "JoinFormDateSession4" "Date séance 4") `Date ;
    join ~name:"comment-session4" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session5" ~label:(adlib "JoinFormFeedbackSession5" "Feedback séance 5") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session5" ~label:(adlib "JoinFormRefSession5" "Ref séance 5") `LongText ;
    join ~name:"date-session5" ~label:(adlib "JoinFormDateSession5" "Date séance 5") `Date ;
    join ~name:"comment-session5" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session6" ~label:(adlib "JoinFormFeedbackSession6" "Feedback séance 6") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session6" ~label:(adlib "JoinFormRefSession6" "Ref séance 6") `LongText ;
    join ~name:"date-session6" ~label:(adlib "JoinFormDateSession6" "Date séance 6") `Date ;
    join ~name:"comment-session6" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session7" ~label:(adlib "JoinFormFeedbackSession7" "Feedback séance 7") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session7" ~label:(adlib "JoinFormRefSession7" "Ref séance 7") `LongText ;
    join ~name:"date-session7" ~label:(adlib "JoinFormDateSession7" "Date séance 7") `Date ;
    join ~name:"comment-session7" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session8" ~label:(adlib "JoinFormFeedbackSession8" "Feedback séance 8") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session8" ~label:(adlib "JoinFormRefSession8" "Ref séance 8") `LongText ;
    join ~name:"date-session8" ~label:(adlib "JoinFormDateSession8" "Date séance 8") `Date ;
    join ~name:"comment-session8" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session9" ~label:(adlib "JoinFormFeedbackSession9" "Feedback séance 9") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session9" ~label:(adlib "JoinFormRefSession9" "Ref séance 9") `LongText ;
    join ~name:"date-session9" ~label:(adlib "JoinFormDateSession9" "Date séance 9") `Date ;
    join ~name:"comment-session9" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session10" ~label:(adlib "JoinFormFeedbackSession10" "Feedback séance 10") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session10" ~label:(adlib "JoinFormRefSession10" "Ref séance 10") `LongText ;
    join ~name:"date-session10" ~label:(adlib "JoinFormDateSession10" "Date séance 10") `Date ;
    join ~name:"comment-session10" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session11" ~label:(adlib "JoinFormFeedbackSession11" "Feedback séance 11") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session11" ~label:(adlib "JoinFormRefSession11" "Ref séance 11") `LongText ;
    join ~name:"date-session11" ~label:(adlib "JoinFormDateSession11" "Date séance 11") `Date ;
    join ~name:"comment-session11" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
    join ~name:"feedback-session12" ~label:(adlib "JoinFormFeedbackSession12" "Feedback séance 12") 
      (`PickOne [
         adlib "JoinFormValuesEasy" "Facile" ;
         adlib "JoinFormValuesSuitable" "Adapté" ;
         adlib "JoinFormValuesHard" "Difficile" ] ) ;
    join ~name:"ref-session12" ~label:(adlib "JoinFormRefSession12" "Ref séance 12") `LongText ;
    join ~name:"date-session12" ~label:(adlib "JoinFormDateSession12" "Date séance 12") `Date ;
    join ~name:"comment-session12" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" "Sujets que vous désirez aborder") `Textarea ;
    join ~name:"othervoice" ~label:(adlib "JoinFieldAgOthervoice" "Si vous ne venez pas, inscrivez ici le nom de la personne à laquelle vous transmettez votre pouvoir") `LongText ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"perimeter" ~label:(adlib "JoinFieldPerimeter" "Périmètre couvert lors de l'opération") `Textarea ;
    join ~name:"action-cr" ~label:(adlib "JoinFieldActionCr" "Compte rendu d'opération") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"theme" ~label:(adlib "JoinFieldTheme" "Thèmes que vous voulez voir aborder") `Textarea ;
    join ~name:"question" ~label:(adlib "JoinFieldQuestion" "Questions que vous souhaitez poser") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" "Sujets que vous désirez aborder") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" "Sujets que vous désirez aborder") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"ok-for-position" ~label:(adlib "JoinFormOkForPosition" "Ok pour être…") 
      (`PickMany [
         adlib "JoinFormOkForPositionPlayer" "Joueur(se)" ;
         adlib "JoinFormOkForPositionCoach" "Coach" ;
         adlib "JoinFormOkForPositionReferee" "Arbitre (et assistant)" ;
         adlib "JoinFormOkForPositionMc" "MC" ] ) ;
    join ~name:"ok-for-help" ~label:(adlib "JoinFormOkForHelp" "Ok pour aider...") 
      (`PickMany [
         adlib "JoinFormOkForHelpTicket" "Caisse" ;
         adlib "JoinFormOkForHelpMusic" "Musique & sono" ;
         adlib "JoinFormOkForHelpSupply" "Courses et nourriture" ;
         adlib "JoinFormOkForHelpOther" "Autre (selon les besoins)" ] ) ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"ok-for-position" ~label:(adlib "JoinFormOkForPosition" "Ok pour être…") 
      (`PickMany [
         adlib "JoinFormOkForPositionPlayer" "Joueur(se)" ;
         adlib "JoinFormOkForPositionCoach" "Coach" ;
         adlib "JoinFormOkForPositionReferee" "Arbitre (et assistant)" ;
         adlib "JoinFormOkForPositionMc" "MC" ] ) ;
    join ~name:"ok-for-help" ~label:(adlib "JoinFormOkForHelp" "Ok pour aider...") 
      (`PickMany [
         adlib "JoinFormOkForHelpTicket" "Caisse" ;
         adlib "JoinFormOkForHelpMusic" "Musique & sono" ;
         adlib "JoinFormOkForHelpSupply" "Courses et nourriture" ;
         adlib "JoinFormOkForHelpOther" "Autre (selon les besoins)" ] ) ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" "Sujets que vous désirez aborder") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Event ~validation:`None ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"comment" ~label:(adlib "JoinFormComment" "Commentaire") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" "Sujets que vous désirez aborder") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`No)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" "Prénom") ~required:true `LongText ;
    join ~name:"sex" ~label:(adlib "JoinFormSex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" "Masculin" ;
         adlib "JoinFormSexFemale" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" "Tel domicile") `LongText ;
    join ~name:"categories-chearleading" ~label:(adlib "JoinFormCategoriesChearleading" "Catégories") ~required:true 
      (`PickOne [
         adlib "JoinFormCategoriesChearleadingLess11fun" "Cheer -11 ans - Loisir" ;
         adlib "JoinFormCategoriesChearleadingLess15fun" "Cheer -15 ans - Loisir" ;
         adlib "JoinFormCategoriesChearleadingMore15fun" "Cheer + 15 ans Loisir" ;
         adlib "JoinFormCategoriesChearleadingMore15compete" "Cheer +15 ans Compétition" ] ) ;
    join ~name:"other-sport-info" ~label:(adlib "JoinFormOtherSportInfo" "Durée, niveau et fréquences des sports déjà pratiqués (ex : natation / confirmé / 2 fois semaine)") `Textarea ;
    join ~name:"job" ~label:(adlib "JoinFormJob" "Profession") `LongText ;
    join ~name:"address" ~label:(adlib "JoinFormAddress" "Adresse") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" "Tel portable") `LongText ;
    join ~name:"info-mother" ~label:(adlib "JoinFormInfoMother" "Si mineur : téléphone, email et profession de la mère") `Textarea ;
    join ~name:"info-father" ~label:(adlib "JoinFormInfoFather" "Si mineur : téléphone, email et profession du père") `Textarea ;
    join ~name:"position-desired" ~label:(adlib "JoinFormPositionDesired" "Poste joué/souhaité") 
      (`PickMany [
         adlib "JoinFormPositionDesiredSpot" "Spot" ;
         adlib "JoinFormPositionDesiredBase" "Base" ;
         adlib "JoinFormPositionDesiredFlyer" "Flyer" ;
         adlib "JoinFormPositionDesiredCoach" "Coach" ] ) ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" "Autres remarques") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" "Prénom") `LongText ;
    join ~name:"workphone" ~label:(adlib "JoinFormWorkphone" "Tel professionnel") `LongText ;
    join ~name:"workmobile" ~label:(adlib "JoinFormWorkmobile" "Portable professionnel") `LongText ;
    join ~name:"workemail" ~label:(adlib "JoinFormWorkemail" "Email professionnel") `LongText ;
    join ~name:"resposabilities-tasks" ~label:(adlib "JoinFormResposabilitiesTasks" "Responsabilités / tâches") `Textarea ;
    join ~name:"day-time-working" ~label:(adlib "JoinFormDayTimeWorking" "Jours et heures d'interventions") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" "Prénom") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" "Tel domicile") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" "Tel portable") `LongText ;
    join ~name:"appartment" ~label:(adlib "JoinFormAppartment" "Appartement(s) (batiment, escalier, étage, numéro)") ~required:true `LongText ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" "Prénom") `LongText ;
    join ~name:"workphone" ~label:(adlib "JoinFormWorkphone" "Tel professionnel") `LongText ;
    join ~name:"workmobile" ~label:(adlib "JoinFormWorkmobile" "Portable professionnel") `LongText ;
    join ~name:"workemail" ~label:(adlib "JoinFormWorkemail" "Email professionnel") `LongText ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" "Prénom") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" "Tel domicile") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" "Tel portable") `LongText ;
    join ~name:"appartment" ~label:(adlib "JoinFormAppartment" "Appartement(s) (batiment, escalier, étage, numéro)") ~required:true `LongText ;
    join ~name:"nb-copro-part" ~label:(adlib "JoinFormNbCoproPart" "Nombre de millièmes") `LongText ;
    join ~name:"live-copro" ~label:(adlib "JoinFormLiveCopro" "Habitez-vous cet appartement ?") 
      (`PickOne [
         adlib "Yes" "Oui" ;
         adlib "No" "Non" ] ) ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"phone" ~label:(adlib "ProfileShareConfigPhone" "Numéro de téléphone") ~required:true `LongText ;
    join ~name:"dateofbirth" ~label:(adlib "ProfileShareConfigBirth" "Date de naissance") ~required:true `LongText ;
    join ~name:"size" ~label:(adlib "JoinFormSize" "Taille") ~required:true `LongText ;
    join ~name:"weight" ~label:(adlib "JoinFormWeight" "Poids") ~required:true `LongText ;
    join ~name:"waist-size" ~label:(adlib "JoinFormWaistSize" "Mensuration : tour de taille") `LongText ;
    join ~name:"thigh-size" ~label:(adlib "JoinFormThighSize" "Mensuration : tour de cuisse") `LongText ;
    join ~name:"actual-level-sport" ~label:(adlib "JoinFormActualLevelSport" "Niveau de pratique sportive actuel") ~required:true 
      (`PickOne [
         adlib "JoinFormValuesBeginner" "Débutant" ;
         adlib "JoinFormValuesAthletic" "Sportif" ;
         adlib "JoinFormValuesConfirmed" "Confirmé" ] ) ;
    join ~name:"objectives" ~label:(adlib "JoinFormObjectives" "Objectifs") ~required:true 
      (`PickMany [
         adlib "JoinFormObjectivesLoseWeight" "Perte de poids" ;
         adlib "JoinFormObjectivesRelaxingWellfare" "Relaxation & bien être" ;
         adlib "JoinFormObjectivesRelaxation" "Assouplissement" ;
         adlib "JoinFormObjectivesToning" "Tonification" ;
         adlib "JoinFormObjectivesPerformance" "Performance" ;
         adlib "JoinFormObjectivesPhysicalPreparation" "Préparation physique générale individualisée" ] ) ;
    join ~name:"actual-sports" ~label:(adlib "JoinFormActualSports" "Sports pratiqués (ou déjà pratiqués)") 
      (`PickMany [
         adlib "JoinFormActualSportsJogging" "Jogging" ;
         adlib "JoinFormActualSportsBiking" "Vélo" ;
         adlib "JoinFormActualSportsRacketSport" "Sport de raquette" ;
         adlib "JoinFormActualSportsCombatSport" "Sport de Combat" ;
         adlib "JoinFormActualSportsIndoorSport" "Sport en Salle" ;
         adlib "JoinFormActualSportsTeamSport" "Sport Collectif" ] ) ;
    join ~name:"othersports" ~label:(adlib "JoinFormOthersports" "autres sports pratiqués ou déjà pratiqués") `Textarea ;
    join ~name:"session-type" ~label:(adlib "JoinFormSessionType" "Type de séance") ~required:true 
      (`PickMany [
         adlib "JoinFormSessionTypePrivate" "Individuel" ;
         adlib "JoinFormSessionTypeCollectif" "collectif" ;
         adlib "JoinFormSessionTypeAlone" "Seul (sans coach)" ] ) ;
    join ~name:"course-type" ~label:(adlib "JoinFormCourseType" "Types de cours souhaités") ~required:true 
      (`PickMany [
         adlib "JoinFormCourseTypeAbsButt" "Abdos-fessiers" ;
         adlib "JoinFormCourseTypeSoftGym" "Gym souple" ;
         adlib "JoinFormCourseTypeStep" "Step" ;
         adlib "JoinFormCourseTypeCardio" "Cardio" ;
         adlib "JoinFormCourseTypeBoxe" "Boxe" ;
         adlib "JoinFormCourseTypeBodybuilding" "Musculation" ] ) ;
    join ~name:"nb-session" ~label:(adlib "JoinFormNbSession" "Nombre séances envisagées hebdomadaires") ~required:true 
      (`PickOne [
         adlib "1" "1" ;
         adlib "2" "2" ;
         adlib "3" "3" ;
         adlib "4" "4" ;
         adlib "5" "5" ] ) ;
    join ~name:"prefered-session-time" ~label:(adlib "JoinFormPreferedSessionTime" "Horaires envisagés pour les séances") ~required:true 
      (`PickMany [
         adlib "JoinFormValuesMorning" "Matin" ;
         adlib "JoinFormValuesNoon" "Midi" ;
         adlib "JoinFormValuesAfternoon" "Après-midi" ;
         adlib "JoinFormValuesEvening" "Soir" ] ) ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" "Autres remarques") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" "Prénom") ~required:true `LongText ;
    join ~name:"sex" ~label:(adlib "JoinFormSex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" "Masculin" ;
         adlib "JoinFormSexFemale" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" "Tel domicile") `LongText ;
    join ~name:"job" ~label:(adlib "JoinFormJob" "Profession") `LongText ;
    join ~name:"address" ~label:(adlib "JoinFormAddress" "Adresse") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" "Tel portable") `LongText ;
    join ~name:"size" ~label:(adlib "JoinFormSize" "Taille") `LongText ;
    join ~name:"experience-footus" ~label:(adlib "JoinFormExperienceFootus" "Expérience Football Américain") `LongText ;
    join ~name:"weight" ~label:(adlib "JoinFormWeight" "Poids") `LongText ;
    join ~name:"info-mother" ~label:(adlib "JoinFormInfoMother" "Si mineur : téléphone, email et profession de la mère") `Textarea ;
    join ~name:"info-father" ~label:(adlib "JoinFormInfoFather" "Si mineur : téléphone, email et profession du père") `Textarea ;
    join ~name:"position-desired" ~label:(adlib "JoinFormPositionDesired" "Poste joué/souhaité") 
      (`PickMany [
         adlib "JoinFormPositionDesiredQb" "QB" ;
         adlib "JoinFormPositionDesiredWr" "WR" ;
         adlib "JoinFormPositionDesiredRb" "RB" ;
         adlib "JoinFormPositionDesiredOl" "OL" ;
         adlib "JoinFormPositionDesiredDl" "DL" ;
         adlib "JoinFormPositionDesiredLb" "LB" ;
         adlib "JoinFormPositionDesiredDb" "DB" ;
         adlib "JoinFormPositionDesiredCoach" "Coach" ] ) ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" "Autres remarques") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"lastname" ~label:(adlib "JoinFormLastname" "Nom") ~required:true `LongText ;
    join ~name:"firstname" ~label:(adlib "JoinFormFirstname" "Prénom") ~required:true `LongText ;
    join ~name:"sex" ~label:(adlib "JoinFormSex" "Sexe") ~required:true 
      (`PickOne [
         adlib "JoinFormSexMale" "Masculin" ;
         adlib "JoinFormSexFemale" "Féminin" ] ) ;
    join ~name:"dateofbirth" ~label:(adlib "JoinFormDateofbirth" "Date de naissance (JJ / MM / AAAA)") ~required:true `Date ;
    join ~name:"placeofbirth" ~label:(adlib "JoinFormPlaceofbirth" "Lieu de naissance") `LongText ;
    join ~name:"homephone" ~label:(adlib "JoinFormHomephone" "Tel domicile") `LongText ;
    join ~name:"mobilephone" ~label:(adlib "JoinFormMobilephone" "Tel portable") `LongText ;
    join ~name:"size" ~label:(adlib "JoinFormSize" "Taille") ~required:true `LongText ;
    join ~name:"weight" ~label:(adlib "JoinFormWeight" "Poids") ~required:true `LongText ;
    join ~name:"grade-judo-jujitsu" ~label:(adlib "JoinFormGradeJudoJujitsu" "Grade Judo / Jujitsu") ~required:true 
      (`PickOne [
         adlib "JoinFormGradeJudoJujitsuNoneBeginner" "Aucun / débutant" ;
         adlib "JoinFormGradeJudoJujitsuWhite" "Ceinture blanche" ;
         adlib "JoinFormGradeJudoJujitsuWhiteYellow" "Ceinture blanche/jaune " ;
         adlib "JoinFormGradeJudoJujitsuYellow" "Ceinture jaune" ;
         adlib "JoinFormGradeJudoJujitsuYellowOrange" "Ceinture jaune/orange" ;
         adlib "JoinFormGradeJudoJujitsuOrange" "Ceinture orange" ;
         adlib "JoinFormGradeJudoJujitsuOrangeGreen" "Ceinture orange/verte" ;
         adlib "JoinFormGradeJudoJujitsuGreen" "Ceinture verte" ;
         adlib "JoinFormGradeJudoJujitsuBlue" "Ceinture bleue" ;
         adlib "JoinFormGradeJudoJujitsuBrown" "Ceinture marron" ;
         adlib "JoinFormGradeJudoJujitsuBlack" "Ceinture noire" ] ) ;
    join ~name:"grade-judo-jujitsu-dan" ~label:(adlib "JoinFormGradeJudoJujitsuDan" "Si ceinture noire, quel dan ?") 
      (`PickOne [
         adlib "JoinFormGradeJudoJujitsuDan1dan" "1er dan" ;
         adlib "JoinFormGradeJudoJujitsuDan2dan" "2nd dan" ;
         adlib "JoinFormGradeJudoJujitsuDan3dan" "3eme dan" ;
         adlib "JoinFormGradeJudoJujitsuDan4dan" "4eme dan" ;
         adlib "JoinFormGradeJudoJujitsuDan5dan" "5eme dan" ;
         adlib "JoinFormGradeJudoJujitsuDan6dan" "6eme dan" ] ) ;
    join ~name:"passport-judo" ~label:(adlib "JoinFormPassportJudo" "Disposez-vous d'un passeport Judo ?") ~required:true 
      (`PickOne [
         adlib "Yes" "Oui" ;
         adlib "No" "Non" ] ) ;
    join ~name:"license-number" ~label:(adlib "JoinFormLicenseNumber" "Numéro de license (si vous en avez un)") `LongText ;
    join ~name:"medical-data-sport" ~label:(adlib "JoinFormMedicalDataSport" "Données médicales concernant votre pratique sportive que vous souhaitez porter à notre connaissance ") `Textarea ;
    join ~name:"other" ~label:(adlib "JoinFormOther" "Autres remarques") `Textarea ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Registered ~grant:`Yes)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Registered ~grant:`Yes)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~join:[
    join ~name:"test" ~label:(adlib "JoinFieldTest" "Est-ce que ce test marche ?") `Checkbox ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`No)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`No)
  ~join:[
    join ~name:"bestevent" ~label:(adlib "JoinPollYearlyBestevent" "Quel évènement vous a le plus marqué cette année concernant notre association ?") `LongText ;
    join ~name:"assiduity" ~label:(adlib "JoinPollYearlyAssiduity" "Comment qualifieriez-vous votre participation dans notre association cette année ?") 
      (`PickOne [
         adlib "JoinFormValuesHuge" "Grande" ;
         adlib "JoinFormValuesBig" "Importante" ;
         adlib "JoinFormValuesOk" "Adéquate" ;
         adlib "JoinFormValuesPoor" "Faible" ;
         adlib "JoinFormValuesNull" "Inexistante" ] ) ;
    join ~name:"satisfaction" ~label:(adlib "JoinPollYearlySatisfaction" "Etes-vous satisfait de l'année qui vient de se passer ?") 
      (`PickOne [
         adlib "Yes" "Oui" ;
         adlib "JoinFormValuesMostly" "Plutôt oui" ;
         adlib "JoinFormValuesMostlyno" "Plutôt non" ;
         adlib "No" "Non" ] ) ;
    join ~name:"3qualtities" ~label:(adlib "JoinPollYearly3qualtities" "Selon vous, quels sont les 3 points forts de notre association ?") `Textarea ;
    join ~name:"3improvements" ~label:(adlib "JoinPollYearly3improvements" "Proposez-nous 3 points d'améliorations pour notre association") `Textarea ;
    join ~name:"comingback" ~label:(adlib "JoinPollYearlyComingback" "On compte sur vous l'année prochaine ?") 
      (`PickOne [
         adlib "Yes" "Oui" ;
         adlib "JoinFormValuesDontknow" "Je ne sais pas" ;
         adlib "No" "Non" ] ) ;
    join ~name:"involvement" ~label:(adlib "JoinPollYearlyInvolvement" "Voulez-vous vous impliquer dans l'organisation ?") 
      (`PickOne [
         adlib "Yes" "Oui" ;
         adlib "No" "Non" ] ) ;
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`Yes)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`Yes)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`Yes)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`Yes)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`None ~read:`Viewers ~grant:`Yes)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`Yes)
  ~join:[
  ]
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
  ~group:(groupConfig ~semantics:`Group ~validation:`Manual ~read:`Viewers ~grant:`Yes)
  ~join:[
  ]
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

