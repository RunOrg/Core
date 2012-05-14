$.extend $$.jog, 
  staticInit: ->
    @$.find('.pretty-button').button().show()
    @$.find('.access-flag').tipsy
      gravity: 'w'
      fade: true
    @$.find('.minitip').each ->
      $me = $(@)
      if $me.attr 'title' 
        $me.addClass('-shown').tipsy 
          gravity: if $me.hasClass('-s') then 'n' else 'w'
          fade: true
      if $me.attr 'href' 
        $me.addClass 'shown' 
    @$.find('.with-js.show-details').click( ->
      do $(@).next().show
      do $(@).hide
    ).next().hide()

jog.reloadListen ->
  do $('.tipsy').remove