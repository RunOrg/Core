$$.runorg.start = do () ->
  keys = {}
  obj = {
    current: null
    refresh: (replace,html,js) -> 
      display = () =>
        if replace
          $html = $('#start').html html
          jog.call jog.extend(@,$html), js
          $html.hide().slideDown 'slow'
      $del = $('#start').children();
      if $del.length 
        $del.slideUp 'slow', display
      else
        do display    
    define: (args) ->
      $.extend keys, args
      return obj
    hint: (key) ->
      hint = keys[key]
      return if !hint
      jog.boxLoad(hint.url) 
      loaded = false
      check = () ->
        return if loaded
        $sel = $(hint.sel) 
        return setTimeout(check, 250) if $sel.length == 0
        loaded = true
        $sel.tipsy 
          title: () -> hint.hint
          gravity:  hint.gravity
          fade:     true
          trigger:  "manual"
        $sel.tipsy "show"
        hide = () -> 
          $('.tipsy').remove()
        setTimeout hide, 20000
        $sel.focus hide
        $sel.click hide
        jog.reloadListen hide
      jog.reloadListen check
  }