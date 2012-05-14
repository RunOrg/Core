$.extend $$.runorg, 
  theDialog: null
  
  dialog: (html,title,code,options) ->

    options = $.extend(
      cls:   "span-10 last"
      width: 414 
      position: ['center',25] 

      options,

      modal:     true
      resizable: false
      title:     title
      stack:     false
      close: -> 
        $(@).remove()
        $$.runorg.theDialog = null
    )

    $$.runorg.theDialog?.dialog 'close'

    $$.runorg.theDialog = $('<div/>')
      .addClass(options.cls)
      .append(html)
      .dialog(options);

    c = -> $: $$.runorg.theDialog
    c:: = @

    $$.jog.call new c, code;

  closeDialog: ->
    $$.runorg.theDialog?.dialog 'close' 
