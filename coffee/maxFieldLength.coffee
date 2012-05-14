runorg.maxFieldLength = (id,length) ->
  $count = $('<label for="'+id+'" class="field-count">&nbsp;</label>');
  $field = @$.find('#'+id);
  
  count = -> $count.text($field.val().length + '/' + length)

  $field.keyup(count).change(count).blur(count)
  setTimeout(count,500)
  $count.insertAfter($field).css
    width: $field.outerWidth()
