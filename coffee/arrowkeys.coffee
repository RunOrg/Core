$('body').keydown (event) ->
  follow = (what) -> 
    return if what.attr 'disabled'
    return unless what.attr 'href'
    document.location = what.attr 'href'
  follow $ '#on-left-arrow' if event.which == 37 
  follow $ '#on-right-arrow' if event.which == 39