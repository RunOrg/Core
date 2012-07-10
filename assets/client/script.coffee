#>> clientBack(url:string option)

@clientBack = (url) -> 
  if url 
    $('#back').show().attr('href',url)
  else
    $('#back').hide()

