(* © 2012 RunOrg *)
open Common

module Col = struct

  let status = 
    column ~sort:true ~show:true ~view:`Status
      ~label:(adlib "ParticipateFieldState" ~old:"participate.field.state" "Statut")
      (`Self `Status)

  let date = 
    column ~sort:true ~show:true ~view:`DateTime
      ~label:(adlib "ParticipateFieldDateShort" ~old:"participate.field.date.short" "Depuis le")
      (`Self `Date) 

end 

module Field = struct

  let desc = 
    field ~label:(adlib "EntityFieldDesc" "Description")
      ~required:true
      ~mean:`Description
      `Textarea "desc" 

  let picture = 
    field ~label:(adlib "EntityFieldPicture" "Image")
      ~mean:`Picture
      `Picture "pic" 

  let date = 
    field ~label:(adlib "EntityFieldDate" "Date")
      ~mean:`Date
      `Date "date" 

  let location = 
    field ~label:(adlib "EntityFieldAddress" "Adresse")
      ~help:(adlib "EntityFieldAddressExplain" "Inscrivez l'adresse complète : un lien automatique est fait vers Google Maps")
      ~mean:`Location
      `LongText "address" 

end

module Page = struct

  let place = 
    infoSection (adlib "Info_Section_Where" "Où ?")   [ infoItem [ infoField "address" `Address ] ]
    
  let time = 
    infoSection (adlib "Info_Section_When" "Quand ?") [ infoItem [ infoField "date" `Date ] ]

end

(* ========================================================================== *)

let admin = template "Admin"
  ~old:"admin"
  ~kind:`Group
  ~name:"Groupe des Administrateurs RunOrg"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:[]
  ~join:[]
  ~page:[]
  ()

(* ========================================================================== *)

let _ = template "AlbumSimple"
  ~old:"album-simple"
  ~kind:`Forum
  ~name:"Album Photo Simple"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:[]
  ~join:[]
  ~page:[]
  ()

(* ========================================================================== *)

let course12sessions = template "Course12sessions"
  ~old:"course-12sessions"
  ~kind:`Event
  ~name:"Cours 12 séances"
  ~desc:"Ce cours permet de suivre par date les activités réalisées lors de 12 séances. Peut être renseigné par l'élève ou le prof"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; date ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession1" ~old:"join.form.date-session1" "Date séance 1")
      (`Self (`Field "date-session1")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session1")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession2" ~old:"join.form.date-session2" "Date séance 2")
      (`Self (`Field "date-session2")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session2")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession3" ~old:"join.form.date-session3" "Date séance 3")
      (`Self (`Field "date-session3")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session3")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession4" ~old:"join.form.date-session4" "Date séance 4")
      (`Self (`Field "date-session4")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session4")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession5" ~old:"join.form.date-session5" "Date séance 5")
      (`Self (`Field "date-session5")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session5")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession6" ~old:"join.form.date-session6" "Date séance 6")
      (`Self (`Field "date-session6")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session6")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession7" ~old:"join.form.date-session7" "Date séance 7")
      (`Self (`Field "date-session7")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session7")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession8" ~old:"join.form.date-session8" "Date séance 8")
      (`Self (`Field "date-session8")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session8")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession9" ~old:"join.form.date-session9" "Date séance 9")
      (`Self (`Field "date-session9")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session9")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession10" ~old:"join.form.date-session10" "Date séance 10")
      (`Self (`Field "date-session10")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session10")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession11" ~old:"join.form.date-session11" "Date séance 11")
      (`Self (`Field "date-session11")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session11")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession12" ~old:"join.form.date-session12" "Date séance 12")
      (`Self (`Field "date-session12")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session12")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ;
    field ~label:(adlib "EntityFieldTeacher" "Formateur")
          `LongText "teacher" ;
    field ~label:(adlib "EntityFieldCurriculum" "Programme du cours")
          `Textarea "curriculum" ;
    field ~label:(adlib "EntityFieldPrerequisite" "Pré-requis")
          `Textarea "prerequisite" ;
  ])
  ~join:[
    join ~name:"date-session1" ~label:(adlib "JoinFormDateSession1" ~old:"join.form.date-session1" "Date séance 1") `Date ;
    join ~name:"comment-session1" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session2" ~label:(adlib "JoinFormDateSession2" ~old:"join.form.date-session2" "Date séance 2") `Date ;
    join ~name:"comment-session2" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session3" ~label:(adlib "JoinFormDateSession3" ~old:"join.form.date-session3" "Date séance 3") `Date ;
    join ~name:"comment-session3" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session4" ~label:(adlib "JoinFormDateSession4" ~old:"join.form.date-session4" "Date séance 4") `Date ;
    join ~name:"comment-session4" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session5" ~label:(adlib "JoinFormDateSession5" ~old:"join.form.date-session5" "Date séance 5") `Date ;
    join ~name:"comment-session5" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session6" ~label:(adlib "JoinFormDateSession6" ~old:"join.form.date-session6" "Date séance 6") `Date ;
    join ~name:"comment-session6" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session7" ~label:(adlib "JoinFormDateSession7" ~old:"join.form.date-session7" "Date séance 7") `Date ;
    join ~name:"comment-session7" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session8" ~label:(adlib "JoinFormDateSession8" ~old:"join.form.date-session8" "Date séance 8") `Date ;
    join ~name:"comment-session8" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session9" ~label:(adlib "JoinFormDateSession9" ~old:"join.form.date-session9" "Date séance 9") `Date ;
    join ~name:"comment-session9" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session10" ~label:(adlib "JoinFormDateSession10" ~old:"join.form.date-session10" "Date séance 10") `Date ;
    join ~name:"comment-session10" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session11" ~label:(adlib "JoinFormDateSession11" ~old:"join.form.date-session11" "Date séance 11") `Date ;
    join ~name:"comment-session11" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"date-session12" ~label:(adlib "JoinFormDateSession12" ~old:"join.form.date-session12" "Date séance 12") `Date ;
    join ~name:"comment-session12" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
        infoItem
          ~label:(adlib "Info_Item_Prerequisite" "Pré-requis")
          [ infoField "prerequisite" `LongText ];
        infoItem
          ~label:(adlib "Info_Item_Curriculum" "Programme du cours")
          [ infoField "curriculum" `LongText ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          ~label:(adlib "Info_Item_Coord" "Formateur")
          [ infoField "teacher" `Text ];
      ];
    place ;
    time 
  ])
  ()

(* ========================================================================== *)

let course12sessionsFitness = template "Course12sessionsFitness"
  ~old:"course-12sessions-fitness"
  ~kind:`Event
  ~name:"Cours 12 séances fitness"
  ~desc:"Ce cours permet de suivre par date les activités réalisées lors de 12 séances et de réccupérer les retours des élèves. Peut être renseigné par l'élève et/ou le prof"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; date ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession1" ~old:"join.form.date-session1" "Date séance 1")
      (`Self (`Field "date-session1")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession1" ~old:"join.form.ref-session1" "Ref séance 1")
      (`Self (`Field "ref-session1")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession1" ~old:"join.form.feedback-session1" "Feedback séance 1")
      (`Self (`Field "feedback-session1")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session1")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession2" ~old:"join.form.date-session2" "Date séance 2")
      (`Self (`Field "date-session2")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession2" ~old:"join.form.ref-session2" "Ref séance 2")
      (`Self (`Field "ref-session2")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession2" ~old:"join.form.feedback-session2" "Feedback séance 2")
      (`Self (`Field "feedback-session2")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session2")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession3" ~old:"join.form.date-session3" "Date séance 3")
      (`Self (`Field "date-session3")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession3" ~old:"join.form.ref-session3" "Ref séance 3")
      (`Self (`Field "ref-session3")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession3" ~old:"join.form.feedback-session3" "Feedback séance 3")
      (`Self (`Field "feedback-session3")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session3")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession4" ~old:"join.form.date-session4" "Date séance 4")
      (`Self (`Field "date-session4")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession4" ~old:"join.form.ref-session4" "Ref séance 4")
      (`Self (`Field "ref-session4")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession4" ~old:"join.form.feedback-session4" "Feedback séance 4")
      (`Self (`Field "feedback-session4")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session4")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession5" ~old:"join.form.date-session5" "Date séance 5")
      (`Self (`Field "date-session5")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession5" ~old:"join.form.ref-session5" "Ref séance 5")
      (`Self (`Field "ref-session5")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession5" ~old:"join.form.feedback-session5" "Feedback séance 5")
      (`Self (`Field "feedback-session5")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session5")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession6" ~old:"join.form.date-session6" "Date séance 6")
      (`Self (`Field "date-session6")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession6" ~old:"join.form.ref-session6" "Ref séance 6")
      (`Self (`Field "ref-session6")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession6" ~old:"join.form.feedback-session6" "Feedback séance 6")
      (`Self (`Field "feedback-session6")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session6")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession7" ~old:"join.form.date-session7" "Date séance 7")
      (`Self (`Field "date-session7")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession7" ~old:"join.form.ref-session7" "Ref séance 7")
      (`Self (`Field "ref-session7")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession7" ~old:"join.form.feedback-session7" "Feedback séance 7")
      (`Self (`Field "feedback-session7")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session7")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession8" ~old:"join.form.date-session8" "Date séance 8")
      (`Self (`Field "date-session8")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession8" ~old:"join.form.ref-session8" "Ref séance 8")
      (`Self (`Field "ref-session8")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession8" ~old:"join.form.feedback-session8" "Feedback séance 8")
      (`Self (`Field "feedback-session8")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session8")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession9" ~old:"join.form.date-session9" "Date séance 9")
      (`Self (`Field "date-session9")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession9" ~old:"join.form.ref-session9" "Ref séance 9")
      (`Self (`Field "ref-session9")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession9" ~old:"join.form.feedback-session9" "Feedback séance 9")
      (`Self (`Field "feedback-session9")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session9")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession10" ~old:"join.form.date-session10" "Date séance 10")
      (`Self (`Field "date-session10")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession10" ~old:"join.form.ref-session10" "Ref séance 10")
      (`Self (`Field "ref-session10")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession10" ~old:"join.form.feedback-session10" "Feedback séance 10")
      (`Self (`Field "feedback-session10")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session10")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession11" ~old:"join.form.date-session11" "Date séance 11")
      (`Self (`Field "date-session11")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession11" ~old:"join.form.ref-session11" "Ref séance 11")
      (`Self (`Field "ref-session11")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession11" ~old:"join.form.feedback-session11" "Feedback séance 11")
      (`Self (`Field "feedback-session11")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session11")) ;
    column ~view:`Date
      ~label:(adlib "JoinFormDateSession12" ~old:"join.form.date-session12" "Date séance 12")
      (`Self (`Field "date-session12")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormRefSession12" ~old:"join.form.ref-session12" "Ref séance 12")
      (`Self (`Field "ref-session12")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormFeedbackSession12" ~old:"join.form.feedback-session12" "Feedback séance 12")
      (`Self (`Field "feedback-session12")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment-session12")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldTeacher" "Formateur")
          `LongText "teacher" ;
    field ~label:(adlib "EntityFieldCurriculum" "Programme du cours")
          `Textarea "curriculum" ;
    field ~label:(adlib "EntityFieldPrerequisite" "Pré-requis")
          `Textarea "prerequisite" ;
  ])
  ~join:[
    join ~name:"feedback-session1" ~label:(adlib "JoinFormFeedbackSession1" ~old:"join.form.feedback-session1" "Feedback séance 1") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session1" ~label:(adlib "JoinFormRefSession1" ~old:"join.form.ref-session1" "Ref séance 1") `LongText ;
    join ~name:"date-session1" ~label:(adlib "JoinFormDateSession1" ~old:"join.form.date-session1" "Date séance 1") `Date ;
    join ~name:"comment-session1" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session2" ~label:(adlib "JoinFormFeedbackSession2" ~old:"join.form.feedback-session2" "Feedback séance 2") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session2" ~label:(adlib "JoinFormRefSession2" ~old:"join.form.ref-session2" "Ref séance 2") `LongText ;
    join ~name:"date-session2" ~label:(adlib "JoinFormDateSession2" ~old:"join.form.date-session2" "Date séance 2") `Date ;
    join ~name:"comment-session2" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session3" ~label:(adlib "JoinFormFeedbackSession3" ~old:"join.form.feedback-session3" "Feedback séance 3") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session3" ~label:(adlib "JoinFormRefSession3" ~old:"join.form.ref-session3" "Ref séance 3") `LongText ;
    join ~name:"date-session3" ~label:(adlib "JoinFormDateSession3" ~old:"join.form.date-session3" "Date séance 3") `Date ;
    join ~name:"comment-session3" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session4" ~label:(adlib "JoinFormFeedbackSession4" ~old:"join.form.feedback-session4" "Feedback séance 4") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session4" ~label:(adlib "JoinFormRefSession4" ~old:"join.form.ref-session4" "Ref séance 4") `LongText ;
    join ~name:"date-session4" ~label:(adlib "JoinFormDateSession4" ~old:"join.form.date-session4" "Date séance 4") `Date ;
    join ~name:"comment-session4" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session5" ~label:(adlib "JoinFormFeedbackSession5" ~old:"join.form.feedback-session5" "Feedback séance 5") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session5" ~label:(adlib "JoinFormRefSession5" ~old:"join.form.ref-session5" "Ref séance 5") `LongText ;
    join ~name:"date-session5" ~label:(adlib "JoinFormDateSession5" ~old:"join.form.date-session5" "Date séance 5") `Date ;
    join ~name:"comment-session5" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session6" ~label:(adlib "JoinFormFeedbackSession6" ~old:"join.form.feedback-session6" "Feedback séance 6") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session6" ~label:(adlib "JoinFormRefSession6" ~old:"join.form.ref-session6" "Ref séance 6") `LongText ;
    join ~name:"date-session6" ~label:(adlib "JoinFormDateSession6" ~old:"join.form.date-session6" "Date séance 6") `Date ;
    join ~name:"comment-session6" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session7" ~label:(adlib "JoinFormFeedbackSession7" ~old:"join.form.feedback-session7" "Feedback séance 7") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session7" ~label:(adlib "JoinFormRefSession7" ~old:"join.form.ref-session7" "Ref séance 7") `LongText ;
    join ~name:"date-session7" ~label:(adlib "JoinFormDateSession7" ~old:"join.form.date-session7" "Date séance 7") `Date ;
    join ~name:"comment-session7" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session8" ~label:(adlib "JoinFormFeedbackSession8" ~old:"join.form.feedback-session8" "Feedback séance 8") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session8" ~label:(adlib "JoinFormRefSession8" ~old:"join.form.ref-session8" "Ref séance 8") `LongText ;
    join ~name:"date-session8" ~label:(adlib "JoinFormDateSession8" ~old:"join.form.date-session8" "Date séance 8") `Date ;
    join ~name:"comment-session8" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session9" ~label:(adlib "JoinFormFeedbackSession9" ~old:"join.form.feedback-session9" "Feedback séance 9") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session9" ~label:(adlib "JoinFormRefSession9" ~old:"join.form.ref-session9" "Ref séance 9") `LongText ;
    join ~name:"date-session9" ~label:(adlib "JoinFormDateSession9" ~old:"join.form.date-session9" "Date séance 9") `Date ;
    join ~name:"comment-session9" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session10" ~label:(adlib "JoinFormFeedbackSession10" ~old:"join.form.feedback-session10" "Feedback séance 10") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session10" ~label:(adlib "JoinFormRefSession10" ~old:"join.form.ref-session10" "Ref séance 10") `LongText ;
    join ~name:"date-session10" ~label:(adlib "JoinFormDateSession10" ~old:"join.form.date-session10" "Date séance 10") `Date ;
    join ~name:"comment-session10" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session11" ~label:(adlib "JoinFormFeedbackSession11" ~old:"join.form.feedback-session11" "Feedback séance 11") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session11" ~label:(adlib "JoinFormRefSession11" ~old:"join.form.ref-session11" "Ref séance 11") `LongText ;
    join ~name:"date-session11" ~label:(adlib "JoinFormDateSession11" ~old:"join.form.date-session11" "Date séance 11") `Date ;
    join ~name:"comment-session11" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
    join ~name:"feedback-session12" ~label:(adlib "JoinFormFeedbackSession12" ~old:"join.form.feedback-session12" "Feedback séance 12") 
      (`PickOne [
         adlib "JoinFormValuesEasy" ~old:"join.form.values.easy" "Facile" ;
         adlib "JoinFormValuesSuitable" ~old:"join.form.values.suitable" "Adapté" ;
         adlib "JoinFormValuesHard" ~old:"join.form.values.hard" "Difficile" ] ) ;
    join ~name:"ref-session12" ~label:(adlib "JoinFormRefSession12" ~old:"join.form.ref-session12" "Ref séance 12") `LongText ;
    join ~name:"date-session12" ~label:(adlib "JoinFormDateSession12" ~old:"join.form.date-session12" "Date séance 12") `Date ;
    join ~name:"comment-session12" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
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
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let courseSimple = template "CourseSimple"
  ~old:"course-simple"
  ~kind:`Event
  ~name:"Séance de cours"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldTeacher" "Formateur")
          `LongText "teacher" ;
    field ~label:(adlib "EntityFieldCurriculum" "Programme du cours")
          `Textarea "curriculum" ;
    field ~label:(adlib "EntityFieldPrerequisite" "Pré-requis")
          `Textarea "prerequisite" ;
  ])
  ~join:[]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
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
    place ; 
    time
  ])
  ()

(* ========================================================================== *)

let courseStage = template "CourseStage"
  ~old:"course-stage"
  ~kind:`Event
  ~name:"Stage"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([
    desc ; picture ; date ;
    field ~label:(adlib "EntityFieldEnddate" "Date de fin")
          `Date "enddate" ;
    location ;
    field ~label:(adlib "EntityFieldMealAccomodation" "Repas et hébergement")
          `Textarea "meal-accomodation" ;
    field ~label:(adlib "EntityFieldTeacher" "Formateur")
          `LongText "teacher" ;
    field ~label:(adlib "EntityFieldCurriculum" "Programme du cours")
          `Textarea "curriculum" ;
    field ~label:(adlib "EntityFieldPrerequisite" "Pré-requis")
          `Textarea "prerequisite" ;
  ])
  ~join:[]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
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
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let courseTraining = template "CourseTraining"
  ~old:"course-training"
  ~kind:`Event
  ~name:"Formation"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldMealAccomodation" "Repas et hébergement")
          `Textarea "meal-accomodation" ;
    field ~label:(adlib "EntityFieldTeacher" "Formateur")
          `LongText "teacher" ;
    field ~label:(adlib "EntityFieldCurriculum" "Programme du cours")
          `Textarea "curriculum" ;
    field ~label:(adlib "EntityFieldPrerequisite" "Pré-requis")
          `Textarea "prerequisite" ;
  ])
  ~join:[]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Moreinfo" "Plus d'info")
      [
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
    place ; 
    time
  ])
  ()

(* ========================================================================== *)

let eventAfterwork = template "EventAfterwork"
  ~old:"event-afterwork"
  ~kind:`Event
  ~name:"Afterwork"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([
    desc ; picture ; date ; location ;
    field ~label:(adlib "EntityFieldInvitationsDiscounts" "Invitations & réductions")
          `Textarea "invitations-discounts" ;
    field ~label:(adlib "EntityFieldTicketing" "Billeterie")
          `Textarea "ticketing" ;
    field ~label:(adlib "EntityFieldPriceInfo" "Infos prix")
          `Textarea "price-info" ;
    field ~label:(adlib "EntityFieldSpecialOffer" "Offre spéciale")
          `Textarea "special-offer" ;
    field ~label:(adlib "EntityFieldBuffet" "Buffet")
          `LongText "buffet" ;
    field ~label:(adlib "EntityFieldDressCode" "Dress code")
          `LongText "dress-code" ;
    field ~label:(adlib "EntityFieldDjs" "DJs")
          `LongText "djs" ;
    field ~label:(adlib "EntityFieldKindOfMusic" "Type de musique")
          `LongText "kind-of-music" ;
    field ~label:(adlib "EntityFieldAmbiance" "Ambiance")
          `Textarea "ambiance" ;
    field ~label:(adlib "EntityFieldTheme" "Thème")
          `LongText "theme" ;
    field ~label:(adlib "EntityFieldTransportationService" "Bus/navette")
          `Textarea "transportation-service" ;
    field ~label:(adlib "EntityFieldCloakroom" "Vestiaire")
          `LongText "cloakroom" ;
    field ~label:(adlib "EntityFieldReservationContact" "Réservations")
          `LongText "reservation-contact" ;
    field ~label:(adlib "EntityFieldContactInfo" "Contact")
          `LongText "contact-info" ;
    field ~label:(adlib "EntityFieldSponsorsPartners" "Sponsors & partenaires")
          `Textarea "sponsors-partners" ;
  ])
  ~join:[]
  ~page:Page.([
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
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let _ = template "EventAfterworkAuto"
  ~old:"event-afterwork-auto"
  ~kind:`Event
  ~name:"Aferwork inscriptions automatiques"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ date ; status ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldInvitationsDiscounts" "Invitations & réductions")
          `Textarea "invitations-discounts" ;
    field ~label:(adlib "EntityFieldTicketing" "Billeterie")
          `Textarea "ticketing" ;
    field ~label:(adlib "EntityFieldPriceInfo" "Infos prix")
          `Textarea "price-info" ;
    field ~label:(adlib "EntityFieldSpecialOffer" "Offre spéciale")
          `Textarea "special-offer" ;
    field ~label:(adlib "EntityFieldBuffet" "Buffet")
          `LongText "buffet" ;
    field ~label:(adlib "EntityFieldDressCode" "Dress code")
          `LongText "dress-code" ;
    field ~label:(adlib "EntityFieldDjs" "DJs")
          `LongText "djs" ;
    field ~label:(adlib "EntityFieldKindOfMusic" "Type de musique")
          `LongText "kind-of-music" ;
    field ~label:(adlib "EntityFieldAmbiance" "Ambiance")
          `Textarea "ambiance" ;
    field ~label:(adlib "EntityFieldTheme" "Thème")
          `LongText "theme" ;
    field ~label:(adlib "EntityFieldTransportationService" "Bus/navette")
          `Textarea "transportation-service" ;
    field ~label:(adlib "EntityFieldCloakroom" "Vestiaire")
          `LongText "cloakroom" ;
    field ~label:(adlib "EntityFieldReservationContact" "Réservations")
          `LongText "reservation-contact" ;
    field ~label:(adlib "EntityFieldContactInfo" "Contact")
          `LongText "contact-info" ;
    field ~label:(adlib "EntityFieldSponsorsPartners" "Sponsors & partenaires")
          `Textarea "sponsors-partners" ;
  ])
  ~join:[]
  ~page:Page.([
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
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let eventAg = template "EventAg"
  ~old:"event-ag"
  ~kind:`Event
  ~name:"Assemblée Générale"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldAgOthervoiceShort" ~old:"join.field.ag.othervoice.short" "Pouvoir")
      (`Self (`Field "othervoice")) ;
    status ; 
    date ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldAgenda" "Ordre du jour")
          `Textarea "agenda" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"subject" 
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" 
		"Sujets que vous désirez aborder")
      `Textarea ;
    join ~name:"othervoice" 
      ~label:(adlib "JoinFieldAgOthervoice" ~old:"join.field.ag.othervoice" 
		"Si vous ne venez pas, inscrivez ici le nom de la personne à laquelle vous transmettez votre pouvoir") 
      `LongText ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let eventBadmintonCompetition = template "EventBadmintonCompetition"
  ~kind:`Event
  ~name:"Tournoi de Badminton"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; 
    date ; 
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFielBadmintonSeries" "Série choisie")
      (`Self (`Field "badminton-series")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldBadmintonTable" "Tableau choisi")
      (`Self (`Field "badminton-table")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldBadmintonDouble" "Partenaire de double (nom, prénom, classement)")
      (`Self (`Field "badminton-double")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldBadmintonMixte" "Partenaire de mixte (nom, prénom, classement)")
      (`Self (`Field "badminton-mixte")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"badminton-series" ~label:(adlib "JoinFielBadmintonSeries" "Série choisie") `LongText ;
    join ~name:"badminton-table" ~label:(adlib "JoinFieldBadmintonTable" "Tableau choisi") `LongText ;
    join ~name:"badminton-double" ~label:(adlib "JoinFieldBadmintonDouble" 
					    "Partenaire de double (nom, prénom, classement)") `Textarea ;
    join ~name:"badminton-mixte" ~label:(adlib "JoinFieldBadmintonMixte" 
					   "Partenaire de mixte (nom, prénom, classement)") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
          ];
      ];
    place ; 
    time
  ])
  ()
  
(* ========================================================================== *)

let eventCampaignAction = template "EventCampaignAction"
  ~old:"event-campaign-action"
  ~kind:`Event
  ~name:"Opération militante"
  ~desc:"Organisez une opération militante et recueillez les CR de cette action"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ; 
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldPerimeter" ~old:"join.field.perimeter" "Périmètre couvert lors de l'opération")
      (`Self (`Field "perimeter")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldActionCr" ~old:"join.field.action-cr" "Compte rendu d'opération")
      (`Self (`Field "action-cr")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ;  
    field ~label:(adlib "EntityFieldActionType" "Type d'opération")
          ~help:(adlib "EntityFieldActionCrExplain" "Tractage, boitage, porte à porte, affichage, phoning, etc.")
          ~required:true
          `LongText "action-type" ;
    field ~label:(adlib "EntityFieldActionZone" "Zones, rues, quartiers")
          `LongText "action-zone" ;
    field ~label:(adlib "EntityFieldActionDetails" "Détails techniques de l'opération")
          `Textarea "action-details" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"perimeter" ~label:(adlib "JoinFieldPerimeter" ~old:"join.field.perimeter" 
				     "Périmètre couvert lors de l'opération") `Textarea ;
    join ~name:"action-cr" ~label:(adlib "JoinFieldActionCr" ~old:"join.field.action-cr" 
				     "Compte rendu d'opération") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_What" "Quoi ?")
      [
        infoItem
          [
            infoField "action-type" `Text ;
          ];
      ];
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_ActionDetails" "Détails techniques de l'opération")
          [
            infoField "action-details" `LongText ;
          ];
      ];
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let eventCampaignMeeting = template "EventCampaignMeeting"
  ~old:"event-campaign-meeting"
  ~kind:`Event
  ~name:"Réunion électorale publique"
  ~desc:"Organisez une réunion électorale et reccueillez les thèmes attendus par les participants"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ; 
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldTheme" ~old:"join.field.theme" "Thèmes que vous voulez voir aborder")
      (`Self (`Field "theme")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldQuestion" ~old:"join.field.question" "Questions que vous souhaitez poser")
      (`Self (`Field "question")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldAgenda" "Ordre du jour")
          `Textarea "agenda" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"theme" ~label:(adlib "JoinFieldTheme" ~old:"join.field.theme" 
				 "Thèmes que vous voulez voir aborder") `Textarea ;
    join ~name:"question" ~label:(adlib "JoinFieldQuestion" ~old:"join.field.question" 
				    "Questions que vous souhaitez poser") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    place ; 
    time
  ])
  ()

(* ========================================================================== *)

let eventClubbing = template "EventClubbing"
  ~old:"event-clubbing"
  ~kind:`Event
  ~name:"Soirée"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldTransportationService" "Bus/navette")
          `Textarea "transportation-service" ;
    field ~label:(adlib "EntityFieldCloakroom" "Vestiaire")
          `LongText "cloakroom" ;
    field ~label:(adlib "EntityFieldReservationContact" "Réservations")
          `LongText "reservation-contact" ;
    field ~label:(adlib "EntityFieldContactInfo" "Contact")
          `LongText "contact-info" ;
    field ~label:(adlib "EntityFieldInvitationsDiscounts" "Invitations & réductions")
          `Textarea "invitations-discounts" ;
    field ~label:(adlib "EntityFieldTicketing" "Billeterie")
          `Textarea "ticketing" ;
    field ~label:(adlib "EntityFieldPriceInfo" "Infos prix")
          `Textarea "price-info" ;
    field ~label:(adlib "EntityFieldDressCode" "Dress code")
          `LongText "dress-code" ;
    field ~label:(adlib "EntityFieldDjs" "DJs")
          `LongText "djs" ;
    field ~label:(adlib "EntityFieldKindOfMusic" "Type de musique")
          `LongText "kind-of-music" ;
    field ~label:(adlib "EntityFieldAmbiance" "Ambiance")
          `Textarea "ambiance" ;
    field ~label:(adlib "EntityFieldTheme" "Thème")
          `LongText "theme" ;
    field ~label:(adlib "EntityFieldSponsorsPartners" "Sponsors & partenaires")
          `Textarea "sponsors-partners" ;
  ])
  ~join:[]
  ~page:Page.([
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
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let _ = template "EventClubbingAuto"
  ~old:"event-clubbing-auto"
  ~kind:`Event
  ~name:"Soirée inscriptions automatiques"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([
    desc ; picture ; date ; location ;
    field ~label:(adlib "EntityFieldInvitationsDiscounts" "Invitations & réductions")
          `Textarea "invitations-discounts" ;
    field ~label:(adlib "EntityFieldTicketing" "Billeterie")
          `Textarea "ticketing" ;
    field ~label:(adlib "EntityFieldPriceInfo" "Infos prix")
          `Textarea "price-info" ;
    field ~label:(adlib "EntityFieldDressCode" "Dress code")
          `LongText "dress-code" ;
    field ~label:(adlib "EntityFieldDjs" "DJs")
          `LongText "djs" ;
    field ~label:(adlib "EntityFieldKindOfMusic" "Type de musique")
          `LongText "kind-of-music" ;
    field ~label:(adlib "EntityFieldAmbiance" "Ambiance")
          `Textarea "ambiance" ;
    field ~label:(adlib "EntityFieldTheme" "Thème")
          `LongText "theme" ;
    field ~label:(adlib "EntityFieldTransportationService" "Bus/navette")
          `Textarea "transportation-service" ;
    field ~label:(adlib "EntityFieldMoreinfo" "Informations complémentaires")
          `Textarea "moreinfo" ;
    field ~label:(adlib "EntityFieldCloakroom" "Vestiaire")
          `LongText "cloakroom" ;
    field ~label:(adlib "EntityFieldReservationContact" "Réservations")
          `LongText "reservation-contact" ;
    field ~label:(adlib "EntityFieldContactInfo" "Contact")
          `LongText "contact-info" ;
    field ~label:(adlib "EntityFieldSponsorsPartners" "Sponsors & partenaires")
          `Textarea "sponsors-partners" ;
  ])
  ~join:[]
  ~page:Page.([
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
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let eventComiteEnt = template "EventComiteEnt"
  ~old:"event-comite-ent"
  ~kind:`Event
  ~name:"Comité d'entreprise"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; 
    date ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldAgenda" "Ordre du jour")
          `Textarea "agenda" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" 
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let eventCoproMeeting = template "EventCoproMeeting"
  ~old:"event-copro-meeting"
  ~kind:`Event
  ~name:"Conseil syndical"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldAgenda" "Ordre du jour")
          `Textarea "agenda" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
    field ~label:(adlib "EntityFieldMoreinfo" "Informations complémentaires")
          `Textarea "moreinfo" ;
  ])
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" 
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;            
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let eventImproSimple = template "EventImproSimple"
  ~old:"event-impro-simple"
  ~kind:`Event
  ~name:"Match d'improvisation"
  ~desc:"Organisation interne d'un match contre une autre équipe"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ;
    date ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormOkForPosition" ~old:"join.form.ok-for-position" "Ok pour être…")
      (`Self (`Field "ok-for-position")) ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormOkForHelp" ~old:"join.form.ok-for-help" "Ok pour aider...")
      (`Self (`Field "ok-for-help")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldPlayerTime" "Heure d'arrivée des joueurs")
          `LongText "player-time" ;
    field ~label:(adlib "EntityFieldAgainstTeam" "Equipe rencontrée")
          `LongText "against-team" ;
    field ~label:(adlib "EntityFieldAgainstTeamUrl" "Son site web")
          `LongText "against-team-url" ;
    field ~label:(adlib "EntityFieldMc" "MC")
          `LongText "mc" ;
    field ~label:(adlib "EntityFieldReferee" "Arbitre")
          `LongText "referee" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"ok-for-position" ~label:(adlib "JoinFormOkForPosition"
					   ~old:"join.form.ok-for-position" "Ok pour être…") 
      (`PickMany [
        adlib "JoinFormOkForPositionPlayer" ~old:"join.form.ok-for-position.player" "Joueur(se)" ;
         adlib "JoinFormOkForPositionCoach" ~old:"join.form.ok-for-position.coach" "Coach" ;
         adlib "JoinFormOkForPositionReferee" ~old:"join.form.ok-for-position.referee" "Arbitre (et assistant)" ;
         adlib "JoinFormOkForPositionMc" ~old:"join.form.ok-for-position.mc" "MC" ] ) ;
    join ~name:"ok-for-help" ~label:(adlib "JoinFormOkForHelp" ~old:"join.form.ok-for-help" "Ok pour aider...") 
      (`PickMany [
         adlib "JoinFormOkForHelpTicket" ~old:"join.form.ok-for-help.ticket" "Caisse" ;
         adlib "JoinFormOkForHelpMusic" ~old:"join.form.ok-for-help.music" "Musique & sono" ;
         adlib "JoinFormOkForHelpSupply" ~old:"join.form.ok-for-help.supply" "Courses et nourriture" ;
         adlib "JoinFormOkForHelpOther" ~old:"join.form.ok-for-help.other" "Autre (selon les besoins)" ] ) ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
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
    place ; 
    time ; 
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
  ])
  ()

(* ========================================================================== *)

let eventImproSpectacle = template "EventImproSpectacle"
  ~old:"event-impro-spectacle"
  ~kind:`Event
  ~name:"Spectacle d'improvisation"
  ~desc:"Organisation interne du spectacle"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormOkForPosition" ~old:"join.form.ok-for-position" "Ok pour être…")
      (`Self (`Field "ok-for-position")) ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormOkForHelp" ~old:"join.form.ok-for-help" "Ok pour aider...")
      (`Self (`Field "ok-for-help")) ;
    column ~sort:true ~show:true ~view:`DateTime
      ~label:(adlib "ParticipateFieldDateShort" ~old:"participate.field.date.short" "Depuis le")
      (`Self `Date) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldPlayerTime" "Heure d'arrivée des joueurs")
          `LongText "player-time" ;
    field ~label:(adlib "EntityFieldMc" "MC")
          `LongText "mc" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"ok-for-position" ~label:(adlib "JoinFormOkForPosition" ~old:"join.form.ok-for-position" "Ok pour être…") 
      (`PickMany [
         adlib "JoinFormOkForPositionPlayer" ~old:"join.form.ok-for-position.player" "Joueur(se)" ;
         adlib "JoinFormOkForPositionMc" ~old:"join.form.ok-for-position.mc" "MC" ] ) ;
    join ~name:"ok-for-help" ~label:(adlib "JoinFormOkForHelp" ~old:"join.form.ok-for-help" "Ok pour aider...") 
      (`PickMany [
         adlib "JoinFormOkForHelpTicket" ~old:"join.form.ok-for-help.ticket" "Caisse" ;
         adlib "JoinFormOkForHelpMusic" ~old:"join.form.ok-for-help.music" "Musique & sono" ;
         adlib "JoinFormOkForHelpSupply" ~old:"join.form.ok-for-help.supply" "Courses et nourriture" ;
         adlib "JoinFormOkForHelpOther" ~old:"join.form.ok-for-help.other" "Autre (selon les besoins)" ] ) ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
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
      ];
    place ; 
    time
  ])
  ()

(* ========================================================================== *)

let eventMeeting = template "EventMeeting"
  ~old:"event-meeting"
  ~kind:`Event
  ~name:"Réunion"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldAgenda" "Ordre du jour")
          `Textarea "agenda" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" 
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    place ; 
    time 
  ])
  ()

(* ========================================================================== *)

let eventPetition = template "EventPetition"
  ~old:"event-petition"
  ~kind:`Event
  ~name:"Pétition"
  ~desc:"Vous pouvez personnaliser les informations demandées aux signataires."
  ~propagate:"members"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ; 
    column ~sort:true ~show:true ~view:`DateTime
      ~label:(adlib "MemberFieldBirthdate" ~old:"member.field.birthdate" "Date de Naissance")
      (`Profile `Birthdate) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "MemberFieldZipcode" ~old:"member.field.zipcode" "Code Postal")
      (`Profile `Zipcode) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; 
    field ~label:(adlib "EntityFieldClosingdate" "Date de clôture")
          `Date "enddate" ;
  ])
  ~join:[
    join ~name:"comment" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
  ]
  ~page:Page.([  
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
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
          ~label:(adlib "Info_Item_Enddate" "Date de fin")
          [
            infoField "enddate" `Date ;
          ];
      ];
  ])
  ()

(* ========================================================================== *)

let eventPublicCommittee = template "EventPublicCommittee"
  ~old:"event-public-comity"
  ~kind:`Event
  ~name:"Conseil municipal"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ; 
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~fields:Field.([
    desc ; picture ; date ; location ; 
    field ~label:(adlib "EntityFieldAgenda" "Ordre du jour")
          `Textarea "agenda" ;
    field ~label:(adlib "EntityFieldCoord" "Coordinateur")
          `LongText "coord" ;
  ])
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject"
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ~page:Page.([
    infoSection
      (adlib "Info_Section_Org" "Organisation")
      [
        infoItem
          [
            infoField "coord" `Text ;
          ];
        infoItem
          ~label:(adlib "Info_Item_Agenda" "Ordre du jour")
          [
            infoField "agenda" `LongText ;
          ];
      ];
    place ; 
    time
  ])
  ()

(* ========================================================================== *)

let eventSimple = template "EventSimple"
  ~old:"event-simple"
  ~kind:`Event
  ~name:"Evènement Simple"
  ~desc:"Une date, un lieu, une liste d'invités."
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([ desc ; picture ; date ; location ])
  ~join:[]
  ~page:Page.([ place ; time ])
  ()

(* ========================================================================== *)

let _ = template "EventSimpleAuto"
  ~old:"event-simple-auto"
  ~kind:`Event
  ~name:"Evènement Simple"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([ desc ; picture ; date ; location ])
  ~join:[]
  ~page:Page.([ place ; time ])
  ()

(* ========================================================================== *)

let forum = template "ForumPublic"
  ~old:"forum-public"
  ~kind:`Forum
  ~name:"Forum"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~wall:(wallConfig ~read:`Viewers ~post:`Viewers)
  ~folder:(folderConfig ~read:`Viewers ~post:`Viewers)
  ~album:(albumConfig ~read:`Viewers ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:[]
  ~join:[]
  ~page:[]
  ()

(* ========================================================================== *)

let groupBadminton = template "GroupBadminton"
  ~kind:`Group
  ~name:"Sportifs Badminton"
  ~desc:"Disposez de toutes les informations demandées à vos sportifs dans le cadre du badminton"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
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
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~sort:true ~show:true ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~sort:true ~show:true ~view:`Text
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

let groupCheerleading = template "GroupCheerleading"
  ~old:"group-cheerleading"
  ~kind:`Group
  ~name:"Sportifs cheerleaders"
  ~desc:"Grâce à ce groupe vous disposez de toutes les informations demandées à des sportifs dans le cadre du cheerleading"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~sort:true ~show:true ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~sort:true ~show:true ~view:`Text
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
    column ~sort:true ~show:true ~view:`PickOne
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

let groupCollaborative = template "GroupCollaborative"
  ~old:"group-collaborative"
  ~kind:`Group
  ~name:"Groupe avec Forum"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let groupCollaborativeAuto = template "GroupCollaborativeAuto"
  ~old:"group-collaborative-auto"
  ~kind:`Group
  ~name:"Groupe avec Forum"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`None ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = template "GroupContact"
  ~old:"group-contact"
  ~kind:`Group
  ~name:"Contacts"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`None ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let groupCoproEmployes = template "GroupCoproEmployes"
  ~old:"group-copro-employes"
  ~kind:`Group
  ~name:"Gardiens / employés"
  ~desc:"Groupe avec forum, dédié aux gardiens et salariés"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ;
    date ; 
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel")
      (`Self (`Field "workphone")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormWorkmobile" ~old:"join.form.workmobile" "Portable professionnel")
      (`Self (`Field "workmobile")) ;
    column ~sort:true ~show:true ~view:`Text
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

let groupCoproLodger = template "GroupCoproLodger"
  ~old:"group-copro-lodger"
  ~kind:`Group
  ~name:"Locataires"
  ~desc:"Groupe avec forum, dédié aux locataires"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ; 
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "Mobilephone" ~old:"mobilephone" "")
      (`Self (`Field "mobilephone")) ;
    column ~sort:true ~show:true ~view:`Text
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

let groupCoproManager = template "GroupCoproManager"
  ~old:"group-copro-manager"
  ~kind:`Group
  ~name:"Gestionnaires"
  ~desc:"Groupe avec forum, dédié aux gestionnaires"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel")
      (`Self (`Field "workphone")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormWorkmobile" ~old:"join.form.workmobile" "Portable professionnel")
      (`Self (`Field "workmobile")) ;
    column ~sort:true ~show:true ~view:`Text
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

let groupCorproOwner = template "GroupCorproOwner"
  ~old:"group-corpro-owner"
  ~kind:`Group
  ~name:"Propriétaires"
  ~desc:"Groupe avec forum, dédié aux propriétaires"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; 
    date ; 
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "Mobilephone" ~old:"mobilephone" "")
      (`Self (`Field "mobilephone")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormAppartment" ~old:"join.form.appartment" "Appartement(s) (batiment, escalier, étage, numéro)")
      (`Self (`Field "appartment")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormNbCoproPart" ~old:"join.form.nb-copro-part" "Nombre de millièmes")
      (`Self (`Field "nb-copro-part")) ;
    column ~sort:true ~show:true ~view:`PickOne
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

let groupFitnessMembers = template "GroupFitnessMembers"
  ~old:"group-fitness-members"
  ~kind:`Group
  ~name:"Sportifs fitness"
  ~desc:"Regroupe les informations demandées à vos sportifs."
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "ProfileShareConfigPhone" ~old:"profile.share.config.phone" "Numéro de téléphone")
      (`Self (`Field "phone")) ;
    column ~sort:true ~show:true ~view:`Text
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
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormSessionType" ~old:"join.form.session-type" "Type de séance")
      (`Self (`Field "session-type")) ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormCourseType" ~old:"join.form.course-type" "Types de cours souhaités")
      (`Self (`Field "course-type")) ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormNbSession" ~old:"join.form.nb-session" "Nombre séances envisagées hebdomadaires")
      (`Self (`Field "nb-session")) ;
    column ~sort:true ~show:true ~view:`PickOne
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

let groupFootus = template "GroupFootus"
  ~old:"group-footus"
  ~kind:`Group
  ~name:"Sportifs football américain"
  ~desc:"Regroupe les informations demandées aux joueurs de football américain"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~sort:true ~show:true ~view:`DateTime
      ~label:(adlib "JoinFormDateofbirth" ~old:"join.form.dateofbirth" "Date de naissance (JJ / MM / AAAA)")
      (`Self (`Field "dateofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormPlaceofbirth" ~old:"join.form.placeofbirth" "Lieu de naissance")
      (`Self (`Field "placeofbirth")) ;
    column ~view:`Text
      ~label:(adlib "JoinFormHomephone" ~old:"join.form.homephone" "Tel domicile")
      (`Self (`Field "homephone")) ;
    column ~sort:true ~show:true ~view:`Text
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

let groupJudoMembers = template "GroupJudoMembers"
  ~old:"group-judo-members"
  ~kind:`Group
  ~name:"Sportifs judo et jujitsu"
  ~desc:"Regroupe les informations demandées aux pratiquants de judo et de jujitsu"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinFormSex" ~old:"join.form.sex" "Sexe")
      (`Self (`Field "sex")) ;
    column ~sort:true ~show:true ~view:`DateTime
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
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormSize" ~old:"join.form.size" "Taille")
      (`Self (`Field "size")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormWeight" ~old:"join.form.weight" "Poids")
      (`Self (`Field "weight")) ;
    column ~sort:true ~show:true ~view:`PickOne
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

let groupRespo = template "GroupRespo"
  ~old:"group-respo"
  ~kind:`Group
  ~name:"Responsables"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

  (* ========================================================================== *)

let groupSchoolParents = template "GroupSchoolParents"
  ~kind:`Group
  ~name:"Parents d'élèves"
  ~desc:"Groupe avec forum, dédié aux parents d'élèves"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormChildrenNames" "Prénom et Nom des enfants scolarisés")
      (`Self (`Field "children-names")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormWorkphone" ~old:"join.form.workphone" "Tel professionnel")
      (`Self (`Field "workphone")) ;
    column ~sort:true ~show:true ~view:`Text
      ~label:(adlib "JoinFormMobile" ~old:"join.form.mobile" "Tel portable")
      (`Self (`Field "mobile")) ;
    column ~sort:true ~show:true ~view:`Text
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

let groupSimple = template "GroupSimple"
  ~old:"group-simple"
  ~kind:`Group
  ~name:"Groupe sans Forum"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Registered)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = template "GroupTest"
  ~old:"group-test"
  ~kind:`Group
  ~name:"Groupe Test"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`None ~read:`Registered)
  ~wall:(wallConfig ~read:`Registered ~post:`Viewers)
  ~folder:(folderConfig ~read:`Registered ~post:`Viewers)
  ~album:(albumConfig ~read:`Registered ~post:`Viewers)
  ()

(* ========================================================================== *)

let pollSimple = template "PollSimple"
  ~old:"poll-simple"
  ~kind:`Poll
  ~name:"Sondage Simple"
  ~desc:"Participation libre"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([ desc ; picture ])
  ()

(* ========================================================================== *)

let pollYearly = template "PollYearly"
  ~old:"poll-yearly"
  ~kind:`Poll
  ~name:"Bilan de l'année écoulée"
  ~desc:"Questions que vous pouvez poser en fin d'année à vos adhérents pour avoir leurs retours"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~show:true ~view:`Text
      ~label:(adlib "JoinPollYearlyBestevent" ~old:"join.poll-yearly.bestevent" "Quel évènement vous a le plus marqué cette année concernant notre association ?")
      (`Self (`Field "bestevent")) ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinPollYearlyAssiduity" ~old:"join.poll-yearly.assiduity" "Comment qualifieriez-vous votre participation dans notre association cette année ?")
      (`Self (`Field "assiduity")) ;
    column ~view:`Text
      ~label:(adlib "JoinPollYearly3qualtities" ~old:"join.poll-yearly.3qualtities" "Selon vous, quels sont les 3 points forts de notre association ?")
      (`Self (`Field "3qualtities")) ;
    column ~view:`Text
      ~label:(adlib "JoinPollYearly3improvements" ~old:"join.poll-yearly.3improvements" "Proposez-nous 3 points d'améliorations pour notre association")
      (`Self (`Field "3improvements")) ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinPollYearlyComingback" ~old:"join.poll-yearly.comingback" "On compte sur vous l'année prochaine ?")
      (`Self (`Field "comingback")) ;
    column ~sort:true ~show:true ~view:`PickOne
      ~label:(adlib "JoinPollYearlyInvolvement" ~old:"join.poll-yearly.involvement" "Voulez-vous vous impliquer dans l'organisation ?")
      (`Self (`Field "involvement")) ;
  ])
  ~fields:Field.([
    desc ; picture 
  ])
  ~join:[
    join ~name:"bestevent" ~label:(adlib "JoinPollYearlyBestevent" ~old:"join.poll-yearly.bestevent" "Quel évènement vous a le plus marqué cette année concernant notre association ?") `LongText ;
    join ~name:"assiduity" ~label:(adlib "JoinPollYearlyAssiduity" ~old:"join.poll-yearly.assiduity" "Comment qualifieriez-vous votre participation dans notre association cette année ?") 
      (`PickOne [
         adlib "JoinFormValuesHuge" ~old:"join.form.values.huge" "Grande" ;
         adlib "JoinFormValuesBig" ~old:"join.form.values.big" "Importante" ;
         adlib "JoinFormValuesOk" ~old:"join.form.values.ok" "Adéquate" ;
         adlib "JoinFormValuesPoor" ~old:"join.form.values.poor" "Faible" ;
         adlib "JoinFormValuesNull" ~old:"join.form.values.null" "Inexistante" ] ) ;
    join ~name:"satisfaction" ~label:(adlib "JoinPollYearlySatisfaction" ~old:"join.poll-yearly.satisfaction" "Etes-vous satisfait de l'année qui vient de se passer ?") 
      (`PickOne [
         adlib "Yes" ~old:"yes" "Oui" ;
         adlib "JoinFormValuesMostly" ~old:"join.form.values.mostly" "Plutôt oui" ;
         adlib "JoinFormValuesMostlyno" ~old:"join.form.values.mostlyno" "Plutôt non" ;
         adlib "No" ~old:"no" "Non" ] ) ;
    join ~name:"3qualtities" ~label:(adlib "JoinPollYearly3qualtities" ~old:"join.poll-yearly.3qualtities" "Selon vous, quels sont les 3 points forts de notre association ?") `Textarea ;
    join ~name:"3improvements" ~label:(adlib "JoinPollYearly3improvements" ~old:"join.poll-yearly.3improvements" "Proposez-nous 3 points d'améliorations pour notre association") `Textarea ;
    join ~name:"comingback" ~label:(adlib "JoinPollYearlyComingback" ~old:"join.poll-yearly.comingback" "On compte sur vous l'année prochaine ?") 
      (`PickOne [
         adlib "Yes" ~old:"yes" "Oui" ;
         adlib "JoinFormValuesDontknow" ~old:"join.form.values.dontknow" "Je ne sais pas" ;
         adlib "No" ~old:"no" "Non" ] ) ;
    join ~name:"involvement" ~label:(adlib "JoinPollYearlyInvolvement" ~old:"join.poll-yearly.involvement" "Voulez-vous vous impliquer dans l'organisation ?") 
      (`PickOne [
         adlib "Yes" ~old:"yes" "Oui" ;
         adlib "No" ~old:"no" "Non" ] ) ;
  ]
  ()

(* ========================================================================== *)

let _ = template "SubscriptionAuto"
  ~old:"subscription-auto"
  ~kind:`Group
  ~name:"Adhésion"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let subscriptionDatetodate = template "SubscriptionDatetodate"
  ~old:"subscription-datetodate"
  ~kind:`Group
  ~name:"Adhésion"
  ~desc:"Date à date : annuelle, semestrielle, etc"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = template "SubscriptionDatetodateAuto"
  ~old:"subscription-datetodate-auto"
  ~kind:`Group
  ~name:"Adhésion date à date automatique"
  ~desc:"Aucune validation par un responsable n’est nécessaire pour qu’un membre adhère. Adhésion avec une date de début et de fin de validité"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let subscriptionForever = template "SubscriptionForever"
  ~old:"subscription-forever"
  ~kind:`Group
  ~name:"Adhésion Permanente"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = template "SubscriptionForeverAuto"
  ~old:"subscription-forever-auto"
  ~kind:`Group
  ~name:"Adhésion permanente automatique"
  ~propagate:"members"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = template "SubscriptionSemester"
  ~old:"subscription-semester"
  ~kind:`Group
  ~name:"Adhésion Semestrielle"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = template "SubscriptionYear"
  ~old:"subscription-year"
  ~kind:`Group
  ~name:"Adhésion Annuelle"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

