runorg.picUploader = (id,url_get,url_put,title) ->
  $fld = @$.find('#'+id)
  $upl = $fld.next()
  $iframe = null

  reload = ->

    location = $iframe.contents().get(0).location.href

    if /confirm/.test location 
      id = /[-a-zA-Z0-9]*\?/.exec(location)[0]
      id = id.substr(0,id.length-1)
      $fld.val(id) if id
      do $upl.find('.i').addClass('load').find('img').remove
      do runorg.closeDialog
      setTimeout check, 2000

    do runorg.closeDialog if /cancel/.test location

  start = => 

   $iframe = $('<iframe/>').attr(
      scrolling: 'no'
      src: url_put
      height: 108
      width: 390
    ).load(reload)

    runorg.dialog $iframe, title, [], {}  
    false

  check = ->
    id = $fld.val()
    $.get url_get, id:id,
      (data) ->
        if data.val 
          $upl.find('.i').removeClass('load').append(
            $('<img/>').attr('src',data.val)
          )
        else
          setTimeout check, 2000 if $upl.is ':visible'
      'json'

  $upl.find('.b button').click start

  $fld.change () ->
    return unless $fld.val() 
    do $upl.find('.i').addClass('load').find('img').remove
    do check
