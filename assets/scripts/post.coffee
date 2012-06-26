window.post = (url,data,callback) ->
  $.ajax
    url: url
    contentType: 'application/json' 
    data: $.toJSON data
    type: 'POST'
    success: (data) -> 
      do callback
      call data.code

window.boxPost = (url,data,callback) -> 
  f = eval('('+url[0]+')')
  a = url[1..]
  a.push data, callback
  f.apply @, a
