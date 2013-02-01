(* © 2012 RunOrg *)
open Common

module Col = struct

  let status = 
    column ~view:`Status
      ~label:(adlib "ParticipateFieldState" ~old:"participate.field.state" "Statut")
      (`Self `Status)

  let date = 
    column ~view:`DateTime
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

let admin = group "Admin"
  ~name:"Groupe des Administrateurs RunOrg"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let course12sessions = event "Course12sessions"
  ~name:"Cours 12 séances"
  ~desc:"Ce cours permet de suivre par date les activités réalisées lors de 12 séances. Peut être renseigné par l'élève ou le prof"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
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
   ()

(* ========================================================================== *)

let course12sessionsFitness = event "Course12sessionsFitness"
  ~name:"Cours 12 séances fitness"
  ~desc:"Ce cours permet de suivre par date les activités réalisées lors de 12 séances et de réccupérer les retours des élèves. Peut être renseigné par l'élève et/ou le prof"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
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
  ()

(* ========================================================================== *)

let courseSimple = event "CourseSimple"
  ~name:"Séance de cours"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let courseStage = event "CourseStage"
  ~name:"Stage"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let courseTraining = event "CourseTraining"
  ~name:"Formation"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let eventAfterwork = event "EventAfterwork"
  ~name:"Afterwork"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = event "EventAfterworkAuto"
  ~name:"Aferwork inscriptions automatiques"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ date ; status ])
  ()

(* ========================================================================== *)

let eventAg = event "EventAg"
  ~name:"Assemblée Générale"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    column ~view:`Text
      ~label:(adlib "JoinFieldAgOthervoiceShort" ~old:"join.field.ag.othervoice.short" "Pouvoir")
      (`Self (`Field "othervoice")) ;
    status ; 
    date ;
    column ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
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
  ()

(* ========================================================================== *)

let eventBadmintonCompetition = event "EventBadmintonCompetition"
  ~name:"Tournoi de Badminton"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; 
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFielBadmintonSeries" "Série choisie")
      (`Self (`Field "badminton-series")) ;
    column ~view:`Text
      ~label:(adlib "JoinFieldBadmintonTable" "Tableau choisi")
      (`Self (`Field "badminton-table")) ;
    column ~view:`Text
      ~label:(adlib "JoinFieldBadmintonDouble" "Partenaire de double (nom, prénom, classement)")
      (`Self (`Field "badminton-double")) ;
    column ~view:`Text
      ~label:(adlib "JoinFieldBadmintonMixte" "Partenaire de mixte (nom, prénom, classement)")
      (`Self (`Field "badminton-mixte")) ;
  ])
  ~join:[
    join ~name:"badminton-series" ~label:(adlib "JoinFielBadmintonSeries" "Série choisie") `LongText ;
    join ~name:"badminton-table" ~label:(adlib "JoinFieldBadmintonTable" "Tableau choisi") `LongText ;
    join ~name:"badminton-double" ~label:(adlib "JoinFieldBadmintonDouble" 
					    "Partenaire de double (nom, prénom, classement)") `Textarea ;
    join ~name:"badminton-mixte" ~label:(adlib "JoinFieldBadmintonMixte" 
					   "Partenaire de mixte (nom, prénom, classement)") `Textarea ;
  ]
  ()
  
(* ========================================================================== *)

let eventCampaignAction = event "EventCampaignAction"
  ~name:"Opération militante"
  ~desc:"Organisez une opération militante et recueillez les CR de cette action"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFieldPerimeter" ~old:"join.field.perimeter" "Périmètre couvert lors de l'opération")
      (`Self (`Field "perimeter")) ;
    column ~view:`Text
      ~label:(adlib "JoinFieldActionCr" ~old:"join.field.action-cr" "Compte rendu d'opération")
      (`Self (`Field "action-cr")) ;
  ])
  ~join:[
    join ~name:"perimeter" ~label:(adlib "JoinFieldPerimeter" ~old:"join.field.perimeter" 
				     "Périmètre couvert lors de l'opération") `Textarea ;
    join ~name:"action-cr" ~label:(adlib "JoinFieldActionCr" ~old:"join.field.action-cr" 
				     "Compte rendu d'opération") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let eventCampaignMeeting = event "EventCampaignMeeting"
  ~name:"Réunion électorale publique"
  ~desc:"Organisez une réunion électorale et reccueillez les thèmes attendus par les participants"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFieldTheme" ~old:"join.field.theme" "Thèmes que vous voulez voir aborder")
      (`Self (`Field "theme")) ;
    column ~view:`Text
      ~label:(adlib "JoinFieldQuestion" ~old:"join.field.question" "Questions que vous souhaitez poser")
      (`Self (`Field "question")) ;
  ])
  ~join:[
    join ~name:"theme" ~label:(adlib "JoinFieldTheme" ~old:"join.field.theme" 
				 "Thèmes que vous voulez voir aborder") `Textarea ;
    join ~name:"question" ~label:(adlib "JoinFieldQuestion" ~old:"join.field.question" 
				    "Questions que vous souhaitez poser") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let eventClubbing = event "EventClubbing"
  ~name:"Soirée"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = event "EventClubbingAuto"
  ~name:"Soirée inscriptions automatiques"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let eventComiteEnt = event "EventComiteEnt"
  ~name:"Comité d'entreprise"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; 
    date ;
    column ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
   ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" 
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let eventCoproMeeting = event "EventCoproMeeting"
  ~name:"Conseil syndical"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ;
    column ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" 
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let eventImproSimple = event "EventImproSimple"
  ~name:"Match d'improvisation"
  ~desc:"Organisation interne d'un match contre une autre équipe"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ;
    date ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormOkForPosition" ~old:"join.form.ok-for-position" "Ok pour être…")
      (`Self (`Field "ok-for-position")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormOkForHelp" ~old:"join.form.ok-for-help" "Ok pour aider...")
      (`Self (`Field "ok-for-help")) ;
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
   ()

(* ========================================================================== *)

let eventImproSpectacle = event "EventImproSpectacle"
  ~name:"Spectacle d'improvisation"
  ~desc:"Organisation interne du spectacle"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormOkForPosition" ~old:"join.form.ok-for-position" "Ok pour être…")
      (`Self (`Field "ok-for-position")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinFormOkForHelp" ~old:"join.form.ok-for-help" "Ok pour aider...")
      (`Self (`Field "ok-for-help")) ;
    column ~view:`DateTime
      ~label:(adlib "ParticipateFieldDateShort" ~old:"participate.field.date.short" "Depuis le")
      (`Self `Date) ;
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
  ()

(* ========================================================================== *)

let eventJudoCompetition = event "EventJudoCompetition"
  ~name:"Compétition de Judo"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ; 
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFielJudoNoteAthlete" "Remarques sportif")
      (`Self (`Field "judo-note-athlete")) ;
  ])
  ~join:[
    join ~name:"judo-note-athlete" ~label:(adlib "JoinFielJudoNoteAthlete" "Remarques du sportif") `LongText ;
      ]
    ()
  

(* ========================================================================== *)

let eventMeeting = event "EventMeeting"
  ~name:"Réunion"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" 
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let eventPetition = event "EventPetition"
  ~name:"Pétition"
  ~desc:"Vous pouvez personnaliser les informations demandées aux signataires."
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([
    status ;
    date ; 
    column ~view:`DateTime
      ~label:(adlib "MemberFieldBirthdate" ~old:"member.field.birthdate" "Date de Naissance")
      (`Profile `Birthdate) ;
    column ~view:`Text
      ~label:(adlib "MemberFieldZipcode" ~old:"member.field.zipcode" "Code Postal")
      (`Profile `Zipcode) ;
    column ~view:`Text
      ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire")
      (`Self (`Field "comment")) ;
  ])
  ~join:[
    join ~name:"comment" ~label:(adlib "JoinFormComment" ~old:"join.form.comment" "Commentaire") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let eventPublicCommittee = event "EventPublicCommittee"
  ~name:"Conseil municipal"
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ 
    status ; 
    date ; 
    column ~view:`Text
      ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject" "Sujets que vous désirez aborder")
      (`Self (`Field "subject")) ;
  ])
  ~join:[
    join ~name:"subject" ~label:(adlib "JoinFieldSubject" ~old:"join.field.subject"
				   "Sujets que vous désirez aborder") `Textarea ;
  ]
  ()

(* ========================================================================== *)

let eventSimple = event "EventSimple"
  ~name:"Evènement Simple"
  ~desc:"Une date, un lieu, une liste d'invités."
  ~group:(groupConfig ~validation:`Manual ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = event "EventSimpleAuto"
  ~name:"Evènement Simple"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~collab:(wallConfig ~read:`Registered ~post:`Viewers)
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

let _ = group "GroupTest"
  ~name:"Groupe Test"
  ()

(* ========================================================================== *)

let pollSimple = event "PollSimple"
  ~name:"Sondage Simple"
  ~desc:"Participation libre"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ~fields:Field.([ desc ; picture ])
  ()

(* ========================================================================== *)

let pollYearly = event "PollYearly"
  ~name:"Bilan de l'année écoulée"
  ~desc:"Questions que vous pouvez poser en fin d'année à vos adhérents pour avoir leurs retours"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([
    status ;
    date ;
    column ~view:`Text
      ~label:(adlib "JoinPollYearlyBestevent" ~old:"join.poll-yearly.bestevent" "Quel évènement vous a le plus marqué cette année concernant notre association ?")
      (`Self (`Field "bestevent")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinPollYearlyAssiduity" ~old:"join.poll-yearly.assiduity" "Comment qualifieriez-vous votre participation dans notre association cette année ?")
      (`Self (`Field "assiduity")) ;
    column ~view:`Text
      ~label:(adlib "JoinPollYearly3qualtities" ~old:"join.poll-yearly.3qualtities" "Selon vous, quels sont les 3 points forts de notre association ?")
      (`Self (`Field "3qualtities")) ;
    column ~view:`Text
      ~label:(adlib "JoinPollYearly3improvements" ~old:"join.poll-yearly.3improvements" "Proposez-nous 3 points d'améliorations pour notre association")
      (`Self (`Field "3improvements")) ;
    column ~view:`PickOne
      ~label:(adlib "JoinPollYearlyComingback" ~old:"join.poll-yearly.comingback" "On compte sur vous l'année prochaine ?")
      (`Self (`Field "comingback")) ;
    column ~view:`PickOne
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

