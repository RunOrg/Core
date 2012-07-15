#>> redirect(url:string,?delay:int) 

@redirect = (url,delay) ->
  act = ->  
    document.location = url 
  if delay > 0 
    setTimeout act, delay 
  else
    do act 