window.post = (url,data,callback) ->
  $.ajax
    url: url
    contentType: 'application/json' 
    data: $.toJSON data
    type: 'POST'
    success: (data) -> 
      do callback
      call data.code