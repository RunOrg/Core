#>> remote(url:string)

window.remote = (url) ->
  ctx = @
  $.getJSON url, {}, (data) -> 
    call data.code