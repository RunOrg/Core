@progress = ($p,pc) ->
  p = (pc * 100).toFixed(0) + "%"
  if !$p.is(":visible")
    $p.show().children().css("width",0)
  $p.children().stop().animate({"width":p},"slow").html(if pc then p + "&nbsp;" else "")
  if pc == 1 
    $p.fadeOut "slow"
