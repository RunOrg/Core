$$.runorg.enlargeDetails = (sel,label,height) ->
  @$.find(sel).each () -> 
    $sel = $(@)
    return if $sel.height() < height
    $sel.css('height',height+'px').addClass('enlarge-details');
    $a = $ '<a href="" class="-show"></a>'
    $a.text(label).appendTo($sel).click () ->
      $sel.css('height','auto').removeClass('enlarge-details')
      $a.remove()
      return false
  
