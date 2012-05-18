#>> remote(url:string)

window.remote = (url) ->
  ctx = @
  $.getJSON url, {}, (data) -> 
    call(ctx,data.code)