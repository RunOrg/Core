(* © 2013 RunOrg *) 

open Ohm
open Ohm.Universal
open BatPervasives

module Core = MMail_core

module PointStats = CouchDB.ReduceView(struct
  module Key = Fmt.String
  module Value = Fmt.Make(struct 
    type json t = <
      ?clicked : int = 0 ;
      ?time    : int = 0 ;
      ?sent    : int = 0 ;
      ?opened  : int = 0 ;
      ?zapped  : int = 0 ;
    >
  end)
  module Design = Core.Design 
  let name = "backdoor-point-stats"
  let map  = "var keys = ['time','sent','opened','clicked','zapped'];
              for (var i = 0; i < keys.length; ++i) {    
                var s = doc[keys[i]];
                if (s === null) continue; 
                var o = {};
                o[keys[i]] = 1;
                emit(s.substr(0,10),o);
              }"
  let reduce = "var r = {};
                for (var i = 0; i < values.length; ++i) {
                  for (var k in values[i]) {
                    if (!(k in r)) r[k] = 0;
                    r[k] += values[i][k];
                  }
                } 
                return r;"
  let group = false
  let level = None
end)

module CrowdStats = CouchDB.ReduceView(struct
  module Key = Fmt.String
  module Value = Fmt.Make(struct 
    type json t = <
      ?clicked : int = 0 ;
      ?time    : int = 0 ;
      ?sent    : int = 0 ;
      ?opened  : int = 0 ;
      ?zapped  : int = 0 ;
    >
  end)
  module Design = Core.Design 
  let name = "backdoor-crowd-stats"
  let map  = "var keys = ['sent','opened','clicked','zapped'], o = {time:1};
              for (var i = 0; i < keys.length; ++i)    
                if (doc[keys[i]] !== null) o[keys[i]] = 1;                              
              emit(doc.time.substr(0,10),o);"
  let reduce = "var r = {};
                for (var i = 0; i < values.length; ++i) {
                  for (var k in values[i]) {
                    if (!(k in r)) r[k] = 0;
                    r[k] += values[i][k];
                  }
                } 
                return r;"
  let group = false
  let level = None
end)
