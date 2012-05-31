@call = (code) ->
  for e,i in code
    eval('(' + e[0] + ')').apply(@,e[1..])
