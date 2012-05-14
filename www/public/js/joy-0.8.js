(function($){

    var mkid = (function(){
	var _uid = 0;
	return function() { return ++_uid; }
    })();
    
    // The default options used when applying the plugin
    var defaultOptions = {
	format : ["array",{content:["string",{}]}],
	autocomplete : {}
    };

    // Create an empty widget with the provided CSS.
    function widget(css) {
	return $('<div class="ui-widget ui-widget-content ui-corner-all"/>').css(css);
    }

    function where($elem) {
	return $elem.data('joyEditor').where;
    }

    function set($elem,value) {
	$elem.data('joyEditor').value = value;
	$elem.val($.toJSON(value));
    }

    function parseref($elem) {
	var ref = $elem.data('joyEditor').refValue;
	set($elem,value_of_tree(ref));
    }

    function mknode_array($elem, edit, value) {

	var $list = $('<ul class="ui-joy-array"/>');

	var $add = 
	    $('<a href="javascript:void(0)" class="ui-joy-action ui-state-default ui-corner-all">'+
	      '<span class="ui-icon ui-icon-circle-plus"/></a>')
	    .hover( function() { $(this).addClass('ui-state-hover'); },
		    function() { $(this).removeClass('ui-state-hover'); })
	    .click( function() { append(tree.ref.length, null); parseref($elem) });

	var tree = {
	    id  : mkid(),
	    type: 'array',
	    edit: edit,
	    $box: $list.add($add),
	    ref : []
	};

	function append(index,value) {
	    var subtree = mknode($elem, edit.content, value);		
	    
	    var $delete = 
		$('<a href="javascript:void(0)" class="ui-joy-action ui-joy-action-side ui-state-default ui-corner-all">'+
		  '<span class="ui-icon ui-icon-circle-minus"/></a>')
		.hover( function() { $(this).addClass('ui-state-hover'); },
			function() { $(this).removeClass('ui-state-hover'); })
		.click( function() { $(this).closest('li').remove(); update.call($list); });
	    
	    var $item = 
		$('<li class="ui-widget ui-widget-content ui-corner-all ui-joy-array-item"/>')
		.append($delete)
		.append(subtree.$box)
		.data('joyEditBind',subtree);
	    
	    tree.ref[index] = subtree;
	    $list.append($item);
	}
	
	if ($.isArray(value))
	    $.each(value,function(i,e){
		append(i,e);
	    });

	function update() {
	    var newlist = [];
	    $(this).children().each(function(i){
		newlist.push($(this).data('joyEditBind'));
	    });
	    tree.ref = newlist;
	    parseref($elem);
	}

	$list.sortable({update:update});
	
	return tree;
    }

    function mknode_dict($elem, edit, value) {

	var $list = $('<ul class="ui-joy-dict"/>');

	var $add = 
	    $('<a href="javascript:void(0)" class="ui-joy-action ui-state-default ui-corner-all">'+
	      '<span class="ui-icon ui-icon-circle-plus"/></a>')
	    .hover( function() { $(this).addClass('ui-state-hover'); },
		    function() { $(this).removeClass('ui-state-hover'); })
	    .click( function() { append("", null); parseref($elem) });

	var tree = {
	    id  : mkid(),
	    type: 'dict',
	    edit: edit,
	    $box: $list.add($add),
	    ref : []
	};

	function append(key,value) {
	    var subtree = mknode($elem, edit.content, value);		
	    
	    var $delete = 
		$('<a href="javascript:void(0)" class="ui-joy-action ui-joy-action-side ui-state-default ui-corner-all">'+
		  '<span class="ui-icon ui-icon-circle-minus"/></a>')
		.hover( function() { $(this).addClass('ui-state-hover'); },
			function() { $(this).removeClass('ui-state-hover'); })
		.click( function() { $(this).closest('li').remove(); update.call($list); });

	    var $key = $('<input class="ui-joy-dict-key" type="text"/>').val(key);
	    var $value = $('<div class="ui-joy-dict-value"/>').append(subtree.$box);

	    var node = {
		key : key,
		value : subtree
	    };

	    $key.change(function(){ node.key = $(this).val(); parseref($elem); });

	    var $item = 
		$('<li class="ui-widget ui-widget-content ui-corner-all ui-joy-dict-item"/>')
		.append($delete)
                .append($key)
		.append($value)
		.data('joyEditBind',node);
	    
	    tree.ref.push(node);
	    $list.append($item);
	}
	
	for (var k in value || {}) {
	    append(k,value[k]);
	}

	function update() {
	    var newlist = [];
	    $(this).children().each(function(i){
		newlist.push($(this).data('joyEditBind'));
	    });
	    tree.ref = newlist;
	    parseref($elem);
	}
	
	return tree;
    }


    function mknode_string($elem, edit, value) {

	value = (typeof value == 'string' ? value : '');

	var $box = 
	    (edit.editor == 'line' 
	     ? $('<input type="text" class="ui-joy-field"/>')
	     : $('<textarea class="ui-joy-field"></textarea>')
	    ).val(value);

	if (edit.autocomplete)
	{
	    $box.autocomplete({
		delay: 0,
		source: $elem.data('joyEditor').options.autocomplete[edit.autocomplete] || [],
		change: function() { $box.change(); }
	    });
	}

	var node = {
	    id  : mkid(),
	    type: 'leaf',
	    edit: edit,
	    $box: $box,
	    ref : value
	};

	$box.change(function(){
	    node.ref = $(this).val();
	    parseref($elem);
	});

	return node;
    }

    function mknode_object($elem, edit, value) {

	var ref = {}, $box = $('<table class="ui-joy-object"/>');

	value = value || {};

	for (var k in edit.fields) 
	{
	    ref[k] = mknode($elem, edit.fields[k].content, value[k]);
	    var $tr = $('<tr><td class="ui-joy-object-key"/><td class="ui-joy-object-value"/></tr>');
	    $tr.children(':first').text(edit.fields[k].label);
	    $tr.children(':last').append(ref[k].$box);
	    $box.append($tr);
	}

	return {
	    id: mkid(),
	    type: 'object',
	    edit: edit,
	    $box: $box,
	    ref : ref
	};	
    }

    function mknode_bool($elem, edit, value) {
	
	value = (value === true);

	var $box = $('<input type="checkbox"/>').attr('checked',value?'checked':'');
	var node = {
	    id: mkid(), 
	    type: 'leaf',
	    edit: edit,
	    $box: $box,
	    ref: value
	};

	function update() {
	    node.ref = $box.is(':checked');
	    parseref($elem);
	}

	$box.click(update).change(update);

	return node;
    }

    function mknode_variant($elem, edit, value) {
	
	var $select = $('<select class="ui-joy-variant-select"></select>'), $div = $('<div/>');
	var dflt = null;
	for (var k in edit.variants) {
	    if (!dflt) dflt = k;
	    $option = $('<option></option>').attr('value',k).text(edit.variants[k].label);
	    $select.append($option);
	}

	key   = $.isArray(value) ? value[0] : (value || dflt);
	value = $.isArray(value) ? value[1] : null;

	var node = {
	    id  : mkid(),
	    type: 'variant',
	    edit: edit,
	    $box: $select.add($div),
	    ref : dflt
	};

	subnode(key,value);

	function subnode(key,value) 
	{
	    key = !(key in edit.variants) ? dflt : key;
	    $select.val(key);
	    var content = edit.variants[key].content || null; 
	    if (null === content) {
		$div.html('');
		node.ref = key;
	    } else {
		var sub = mknode($elem, content, value);
		$div.html('').append(sub.$box);
		node.ref = [key,sub];
	    }
	}

	$select.change(function(){
	    var value = $.isArray(node.ref) ? node.ref[1] : null;
	    var key   = $(this).val();
	    subnode(key,value);
	    parseref($elem);
	});

	return node;	
    }

    function mknode_tuple($elem, edit, value) {

	var ref = [], $box = $('<table class="ui-joy-object"/>');

	value = value || [];

	$.each(edit.fields,function(i,e) {	
	    ref[i] = mknode($elem, e[1], value[i] || null);
	    var $tr = $('<tr><td class="ui-joy-object-key"/><td class="ui-joy-object-value"/></tr>');
	    $tr.children(':first').text(e[0]);
	    $tr.children(':last').append(ref[i].$box);
	    $box.append($tr);
	});

	return {
	    id: mkid(),
	    type: 'tuple',
	    edit: edit,
	    $box: $box,
	    ref : ref
	};	
    }

    function mknode_label($elem, edit, value) {

	var $box = $('<table class="ui-joy-object"/>');

	var ref = mknode($elem, edit.content, value);
	var $tr = $('<tr><td class="ui-joy-object-key"/><td class="ui-joy-object-value"/></tr>');
	$tr.children(':first').text(edit.label);
	$tr.children(':last').append(ref.$box);
	$box.append($tr);	

	return {
	    id: mkid(),
	    type: 'label',
	    edit: edit,
	    $box: $box,
	    ref : ref
	};	
    }

    function mknode_option($elem, edit, value) {
	
	var $box = $('<div/>');

	var node = {
	    id  : mkid(),
	    type: 'option',
	    edit: edit, 
	    $box: $box,
	    ref : null
	};
	
	function setnone() 
	{
	    var $add = 
		$('<a href="javascript:void(0)" class="ui-joy-action ui-state-default ui-corner-all">'+
		  '<span class="ui-icon ui-icon-circle-plus"/></a>')
		.hover( function() { $(this).addClass('ui-state-hover'); },
			function() { $(this).removeClass('ui-state-hover'); })
		.click( function() { setsome(null); parseref($elem) });	    

	    $box.empty().append($add);
	    node.ref = null;
	}

	function setsome(value)
	{
	    var $delete = 
		$('<a href="javascript:void(0)" class="ui-joy-action ui-joy-action-side ui-state-default ui-corner-all">'+
		  '<span class="ui-icon ui-icon-circle-minus"/></a>')
		.hover( function() { $(this).addClass('ui-state-hover'); },
			function() { $(this).removeClass('ui-state-hover'); })
		.click( function() { setnone(); parseref($elem); });
	    
	    node.ref = mknode($elem, edit.content, value);

	    var $item = 
		$('<div class="ui-widget ui-widget-content ui-corner-all ui-joy-option-item"/>')
		.append($delete)
		.append(node.ref.$box);

	    var $content = $('<div class="ui-joy-option"/>').append($item);

	    $box.empty().append($content);
	}

	if (value !== null) setsome(value); else setnone();

	return node;
    }

    function mknode($elem, type, value) {
	switch (type[0]) {
	case 'array'  : return mknode_array($elem, type[1], value);
	case 'dict'   : return mknode_dict($elem, type[1], value);
	case 'string' : return mknode_string($elem, type[1], value); 
	case 'bool'   : return mknode_bool($elem, type[1], value); 
	case 'object' : return mknode_object($elem, type[1], value); 
	case 'variant': return mknode_variant($elem, type[1], value);
	case 'tuple'  : return mknode_tuple($elem, type[1], value);
	case 'label'  : return mknode_label($elem, type[1], value);
	case 'option' : return mknode_option($elem, type[1], value);
	}

	console.log("Unknown type: %o", type[0]);
    }

    function value_of_tree(tree) {
	switch (tree.type) {
	case 'option':
	    if (tree.ref === null) return null;
	    return value_of_tree(tree.ref);
	case 'variant': 
	    var result = tree.ref;
	    if ($.isArray(result))
		result = [ result[0], value_of_tree(result[1]) ];
	    return result;
	case 'object': 
	    var result = {};
	    for (var k in tree.ref) result[k] = value_of_tree(tree.ref[k]);
	    return result;
	case 'dict': 
	    var result = {};
	    $.each(tree.ref,function(i,e){result[e.key] = value_of_tree(e.value);});
	    return result;
	case 'array': 
	case 'tuple':
	    var result = [];
	    $.each(tree.ref,function(i,e){result[i] = value_of_tree(e);});
	    return result;
	case 'label': 
	    return value_of_tree(tree.ref);
	case 'leaf':
	    return tree.ref;
	}
    }

    // Ensure that the element houses a valid editor
    function ensure(options) {

	if (this.data('joyEditor')) return;

	var where = widget({padding:10});

	this.data('joyEditor', {
	    options: options || defaultOptions,
            value: $.evalJSON(this.val() || 'null'),
	    where: where
	});

	this.change(function(){
	    $(this).joyEditor('value',$.evalJSON($(this).val() || 'null'));
	});
	
	this.after(where).hide();

	refresh.call(this);
    }

    // Re-render the contents.
    function refresh() {

	ensure.call(this);

	var data = this.data('joyEditor');

	data.refValue = mknode(this, data.options.format, data.value);
	data.where.html('').append(data.refValue.$box);		
    }

    // Extract the value of the editor (stored in the underlying element
    // value as well), or set the value of the editor.
    function value() {

	ensure.call(this);

	if (arguments.length == 0) 
	    return this.data('joyEditor').value;

	set(this,arguments[0]);

	refresh.call(this);
    }

    // Apply a single function to all selected elements, return either an
    // array, or a single result if only one element is selected.
    function map(f,a,args) {
	var r = [];
	a.each(function(i,e){ r[i] = f.apply($(e),args); });	
	if (r.length == 1) return r[0]; 
	return r;
    }

    $.fn.joyEditor = function() {

	var args  = Array.prototype.slice.call(arguments);
	var first = args.length > 0 ? args.shift() : {}

	if (typeof first == "string") {
	    switch (first) {
	    case "value": return map(value,this,args);	   
	    case "refresh": return map(refresh,this,args);
	    }
	}

	var options = $.extend({},defaultOptions,first);

	return map(ensure,this,[options]);
    };
    
})(jQuery);

