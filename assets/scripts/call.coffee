call = (ctx,code) ->
  for e,i in code
    f = eval('(' + e[0] + ')')
    f.apply(ctx,e[1..])
