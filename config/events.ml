(* © 2013 RunOrg *)
open Common

(* ========================================================================== *)

let course12sessions = event "Course12sessions"
  ~name:"Cours 12 séances"
  ~desc:"Ce cours permet de suivre par date les activités réalisées lors de 12 séances. Peut être renseigné par l'élève ou le prof"
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
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let courseStage = event "CourseStage"
  ~name:"Stage"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let courseTraining = event "CourseTraining"
  ~name:"Formation"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let eventAfterwork = event "EventAfterwork"
  ~name:"Afterwork"
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = event "EventAfterworkAuto"
  ~name:"Aferwork inscriptions automatiques"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ date ; status ])
  ()

(* ========================================================================== *)

let eventAg = event "EventAg"
  ~name:"Assemblée Générale"
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
  ~name:"Réunion publique"
  ~desc:"Organisez une réunion électorale et reccueillez les thèmes attendus par les participants"
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
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = event "EventClubbingAuto"
  ~name:"Soirée inscriptions automatiques"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let eventComiteEnt = event "EventComiteEnt"
  ~name:"Comité d'entreprise"
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
  ~columns:Col.([ status ; date ])
  ()

(* ========================================================================== *)

let _ = event "EventSimpleAuto"
  ~name:"Evènement Simple"
  ~group:(groupConfig ~validation:`None ~read:`Viewers)
  ~columns:Col.([ status ; date ])
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

