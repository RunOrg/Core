(* © 2012 RunOrg *)

module Config = Ohm.Fmt.Make(struct 
  module Float = Ohm.Fmt.Float 
  type json t = <
    closed_on "ct" : Float.t option ;
    opened_on "ot" : Float.t option 
  > 
end)

module Question = Ohm.Fmt.Make(struct
  type json t = <
    question "q" : [`label "l" of string | `text "t" of string] ; 
    answers  "a" : [`label "l" of string | `text "t" of string] list ;
    multiple "m" : bool 
  >
end) 
