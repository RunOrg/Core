var admin = {

    joy : function(id,format,autocomplete) {
	$('#'+id).joyEditor({format:format,autocomplete:autocomplete||{}});
    }

};