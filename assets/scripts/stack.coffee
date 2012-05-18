class SubStack 

  constructor: (ctx,sel) -> 
    
    @$ = ctx.$.find(sel)
    @w  = @$.width()
    @stack = []
        
    if @$.children().length	
      $old = @$.children().clone true
      	
    @$.html '<div><div/></div>'
    @$c = @$.children().css { overflow: 'hidden' } 
    @$l = @$c.children().css { position: 'relative', overflow: 'hidden', left: '0px' } 
    
    @i  = 0

    if $old 
      @push 'initial', $old

  pop: () ->
    while @stack.length > 1 + @i
      j = @stack.length - 1
      do @stack[j][1].parent().remove
      @stack.length = j      
    @$l.css { width: @w * @stack.length } 
  
  push: (key,$what,data) ->
    do @pop 
    @stack.push([key,$what,data])
    $box = $('<div/>').append($what).css 
      width: @w + 'px'  
      float: 'left' 
      overflow: 'hidden' 
    @$l.append $box
    @$l.css { width: @w * @stack.length } 
    @move(@stack.length-1)

  move: (i) ->
    @show(i)  
    @i = i
    @$l.stop().animate { left : (- @i * @w) + 'px' }, 'fast', () => 
      do @pop
      do @hide

  show: (i) -> 
    while i < @i 
      @stack[i][1].css height: 'auto'
      ++i
    while i > @i
      @stack[i][1].css height: 'auto' 
      --i

  hide: () -> 
    for e,i in @stack 
      if i != @i 
        e[1].css height: '1px'
  
  find: (key) -> 
    for e,i in @stack 
      return i if e[0] = key 
    return null

  goto: (key,$what,data) -> 
    i = @find key 
    if i is not null
      @move i
    else
      @push key, $what, data
    
  back: () -> 
    @move(@i - 1)

theStack = null
getStack = () -> 
  if theStack is null
    theStack = new SubStack { $: $('body') }, '#substack'
  theStack

#>> stackPush(html:html) 

window.stackPush = (html) -> 
  s = getStack()
  $h = $(html.html) 
  s.push('dialog',$h)
  call { $: $h }, html.code

#>> stackBack()

window.stackBack = () -> 
  s = getStack() 
  do s.back
