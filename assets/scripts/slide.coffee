doSlide = (dir,$s,what) -> 

  $n = $ what.html
  w  = $s.outerWidth()

  css = 
    width: w + 'px'
    float: 'left' 
    marginRight: 15 + 'px'
    overflow: 'hidden' 

  if $s.data('slides')
    $o = $s.parent()
    $l = $o.parent()
  else
    $w = $('<div/>').insertAfter $s
    $s.detach()
    $o = $('<div/>').append($s).css css
    $l = $('<div/>').append($o).css 
      position: 'relative' 
      overflow: 'hidden' 
      left: 0
      width: 2 * (15 + w)
    $c = $('<div/>').append($l).css { overflow: 'hidden' }
    $w.append $c

  if $l.children().length > 1 
    $l.stop()
    $o.detach() 
    do $l.children().remove
    $l.append $o

  $b = $('<div/>').append($n).css css
  $l[if dir then 'append' else 'prepend'] $b
  $n.data('slides',true)
  call what.code       

  $l.css({ left: if dir then 0 else -15 - w }).animate 
    left: if dir then - 15 - w else 0, 
    500,
    () -> 
      $l.css { left : 0 } 
      do $o.remove

@slide = ($s,what) -> 
  doSlide true, $s, what

@unslide = ($s,what) -> 
  doSlide false, $s, what