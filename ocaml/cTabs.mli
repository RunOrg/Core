(* © 2012 RunOrg *)

type ('prefix,'switch) tab 

val fixed : 'switch -> Ohm.I18n.text -> ('prefix * 'switch) O.box Lazy.t -> ('prefix, 'switch) tab

val hidden : ('switch -> (Ohm.I18n.text * ('prefix * 'switch) O.box) option O.run) -> ('prefix, 'switch) tab

val box : 
     list:('prefix, 'switch) tab list 
  -> default:'switch
  -> url:(('prefix * 'switch) O.Box.Seg.set -> ('prefix * 'switch) -> string)
  -> seg:('switch -> 'switch O.Box.Seg.t) 
  -> i18n:Ohm.I18n.t
  -> 'prefix O.box

val vertical : 
     list:('prefix, 'switch) tab list
  -> default:'switch
  -> url:(('prefix * 'switch) O.Box.Seg.set -> ('prefix * 'switch) -> string)
  -> seg:('switch -> 'switch O.Box.Seg.t)
  -> i18n:Ohm.I18n.t
  -> 'prefix O.box


