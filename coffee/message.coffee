$.extend $$.runorg, 
  _msglife: 0

  message: (html,code) -> 
    $('#message').stop().fadeOut 'fast', =>
      if (html || code.length)
        $html = $('#message > span').html html	 
        jog.call jog.extend(@,$html), code
        $('#message').fadeTo 'fast', 1
        runorg._msglife = +(new Date()) + 10000

if $('#message').length 
  jog.reloadListen ->
    runorg.message('',[]) if (+(new Date()) > runorg._msglife)