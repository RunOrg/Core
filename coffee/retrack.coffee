$.extend $$.runorg, 
  retrack: () -> 
    $.post '/retrack', {}, (data) -> 
      console.log "SESSION %s, TEST %s", data.session, data.test
    return