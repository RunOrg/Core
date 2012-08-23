@to_endpoint = (endpoint, data, callback) ->
  if typeof endpoint is 'string'
    send = (data,callback) -> 
      $.ajax
         url: endpoint
         data: $.toJSON data
         type: 'POST'
         contentType: 'application/json'
         success: callback 
  else
    send = (data,callback) -> 
      f = eval('('+endpoint[0]+')')
      a = endpoint[1..]
      a.push data, callback
      f.apply @, a
  send data, callback