var joy = (function($){

    function select($where,selector) 
    {
	if (selector == '') return $where;
	return $where.find(selector);
    }

    function execute(ctx,$where,code) 
    {
	function c() {
            this.$ = $where;
	}
	c.prototype = ctx;
	ctx = new c;
	$.each(code,function(i,e) {
	    var f = eval('('+e[0]+')');
	    f.apply(ctx,e.slice(1));
	}); 
    }

    var lastid = 0;
    function gen() 
    {
	return 'joy_id_'+(++lastid);
    }

    /* Joy nodes are objects that implement the following interface: 

       ## constructor(ctx,config)
       ## identify($where)
       ## render($where)
       ## set(value)
       ## get() 
       ## error(path,text)
       ## clear()
       ## remove() 
    */

    // HTML rendering node ----------------------------------------------------------

    function node_html(ctx,config) 
    {
	this.config = config;
	this.ctx    = ctx;
	this.inner  = recurse(ctx,config.i);    
    }

    node_html.prototype = {
	render: function($where) {
	    this.$inner = $(this.config.h[0]);
	    select($where,this.config.s).append(this.$inner);
	    this.inner.identify(this.$inner);
	    execute(this.ctx,this.$inner,this.config.h[1]);
	    this.inner.render(this.$inner);
	},
	identify: function($where) {},
	set: function(value) { this.inner.set(value); },
	get: function() { return this.inner.get(); },
	remove: function() { this.$inner.remove(); },
	error: function(path,text) { this.inner.error(path,text) },
	clear: function() { this.inner.clear() }
    };

    // Array node -------------------------------------------------------------------

    function node_array(ctx,config)
    {
	this.config = config;
	this.ctx    = ctx;
	this.value  = [];
    }

    node_array.prototype = {
	append: function(value) {
	    var $item = $(this.config.ih[0]), inner = recurse(this.ctx,this.config.i),
	         self = this;
	    this.$list.append($item);
	    $item.data('joy',inner);
	    inner.identify($item);
	    execute(this.ctx,$item,this.config.ih[1]);
	    inner.render($item);
	    inner.set(value);
	    select($item,this.config.rs).click(function(){
		$item.remove();
                self.toggle();
	    });
	    this.toggle();
	},
	toggle: function() {
	    this.$add.toggle(
		!this.config.max || this.$list.children().length < this.config.max);
	},
	identify: function() {},
	render: function($where) {
	    var self = this;
	    this.$list = select($where,this.config.ls);
	    this.$add  = select($where,this.config.as).click(function(){
		self.append(null);
	    });
	},
	set: function(value) {
	    var self = this;
	    this.remove();
	    $.each(value,function(i,e){self.append(e)});
	},
	get: function(value) {
	    var out = [];
	    this.$list.children().each(function(i){
		out.push($(this).data('joy').get());
	    });
	    return out;
	},
	remove: function(){
	    this.$list.children().remove();
	    
	},
	clear: function(value) {
	    this.$list.children().each(function(i){
		$(this).data('joy').clear();
	    });	    
	},
	error: function(path,text) { 
	    var where = path.shift() || 0, children = this.$list.children();
	    if (where >= 0 && where < children.length) {
		children.eq(where).data('joy').error(path,text);
	    }
	}
    };

    // Concatenation node -----------------------------------------------------------

    function node_concat(ctx,config) 
    {
	this.ctx   = ctx;
	this.left  = recurse(ctx,config[0]);
	this.right = recurse(ctx,config[1]);
    }

    node_concat.prototype = {
	identify: function($where) {
	    this.left.identify($where);
	    this.right.identify($where);
	},
	render: function($where) {
	    this.left.render($where);
	    this.right.render($where);
	},
	set: function(value) 
	{
	    value = value || [null,null];
	    this.left.set(value[0] || null);
	    this.right.set(value[1] || null);
	},
	get: function() 
	{
	    return [
		this.left.get(),
		this.right.get()
	    ]
	},
	remove: function() 
	{
	    this.left.remove();
	    this.right.remove();
	},
	error: function(path,text) {
	    var where = path.shift();
	    if (where == 0) this.left.error(path,text);
	    if (where == 1) this.right.error(path,text);
	},
	clear: function() {
	    this.left.clear();
	    this.right.clear();
	}
    };

    // Empty node -------------------------------------------------------------------

    var node_empty =
    {
	set:function() {},
	get:function() { return null },
	remove:function() {},
	error:function() {},
	clear:function() {},
	render:function() {},
	identify:function() {}
    };    

    // String node ------------------------------------------------------------------

    function node_string(ctx,config) 
    {
	this.ctx    = ctx;
	this.id     = gen();
	this.config = config;
    }

    node_string.prototype = {
	render: function($where) {
	    	    
	    this.$label = $('<label/>');
	    
	    if ('ls' in this.config) {
		
		var $labelWrap = $where;
		
		if ('lh' in this.config) {	    
		    $labelWrap = $(this.config.lh[0]);
		    select($where,this.config.lhs).append($labelWrap);
		}
		
		this.$label = select($labelWrap,this.config.ls).attr('for',this.id).text(this.config.lt);

		if ('lh' in this.config) {
		    execute(this.ctx,$labelWrap,this.config.lh[1]);
		}
	    }
	    
	    this.$error = $('<label/>');
	    
	    if ('es' in this.config) {
		
		var $errorWrap = $where;
		
		if ('eh' in this.config) {
		    $errorWrap = $(this.config.eh[0]);
		    select($where,this.config.ehs).append($errorWrap);
		}
		
		this.$error = select($errorWrap,this.config.es).attr('for',this.id);	    

		if ('eh' in this.config) {
		    execute(this.ctx,$errorWrap,this.config.eh[1]);
		}
	    }
	    
	    var $fieldWrap = $where;
	    
	    if ('fh' in this.config) {
		$fieldWrap = $(this.config.fh[0]);
		select($where,this.config.fhs).append($fieldWrap);
	    }

	    this.$field = select($fieldWrap,this.config.s)

	    if ('fh' in this.config) {
		this.$field.attr('id',this.id);
		execute(this.ctx,$fieldWrap,this.config.fh[1]);
	    }	    	   
	},
	identify: function($where) {
	    if ('fh' in this.config) return;
	    select($where,this.config.s).attr('id',this.id);
	},
	set: function(value) 
	{
	    this.$field.val(value || '');
	},
	get: function() 
	{
	    return this.$field.val();
	},
	remove: function()
	{
	    this.$label.remove();
	    this.$error.remove();
	    this.$field.remove();
	},
	error: function(path,text) 
	{
	    if (path.length > 0) return;
	    this.$error.text(text);	    
	},
	clear: function() 
	{
	    this.$error.text('');
	}
    };

    // Choice node ------------------------------------------------------------------

    function node_choice(ctx,config) 
    {
	this.ctx    = ctx;
	this.id     = gen();
	this.config = config;
    }

    node_choice.prototype = {
	render: function($where) {
	    	    
	    this.$label = $('<label/>');
	    
	    if ('ls' in this.config) {
		
		var $labelWrap = $where;
		
		if ('lh' in this.config) {	    
		    $labelWrap = $(this.config.lh[0]);
		    select($where,this.config.lhs).append($labelWrap);
		}
		
		this.$label = select($labelWrap,this.config.ls).attr('for',this.id).text(this.config.lt);

		if ('lh' in this.config) {
		    execute(this.ctx,$labelWrap,this.config.lh[1]);
		}
	    }
	    
	    this.$error = $('<label/>');
	    
	    if ('es' in this.config) {
		
		var $errorWrap = $where;
		
		if ('eh' in this.config) {
		    $errorWrap = $(this.config.eh[0]);
		    select($where,this.config.ehs).append($errorWrap);
		}
		
		this.$error = select($errorWrap,this.config.es).attr('for',this.id);	    

		if ('eh' in this.config) {
		    execute(this.ctx,$errorWrap,this.config.eh[1]);
		}
	    }
	    
	    var $fieldWrap = $where;
	    
	    if ('fh' in this.config) {
		$fieldWrap = $(this.config.fh[0]);
		select($where,this.config.fhs).append($fieldWrap);
	    }

	    this.$field = select($fieldWrap,this.config.s)

	    if ('fh' in this.config) {
		this.$field.attr('id',this.id);
		execute(this.ctx,$fieldWrap,this.config.fh[1]);
	    }	    

	    var self = this, html = [];

	    $.each(this.config.src,function(i,e){
		html.push('<label>');
		if (self.config.m) {
		    html.push('<input type="checkbox" name="',
			      self.id + '-' + i,
			      '" value="', i, '"/>'); 
		} else {
		    html.push('<input type="radio" name="',
			      self.id,
			      '" value="', i, '"/>');
		}
		html.push(e.html);
		html.push('</label>');
	    });

	    this.$field.html(html.join(''));
	},
	identify: function($where) {},
	set: function(values) 
	{
	    values = values || [];
	    this.$field.find('input:checked').attr('checked', '');
	    var self = this;
	    $.each(this.config.src,function(i,e){
		if (-1 === $.inArray(e.internal,values)) return
		self.$field.find('input[value='+i+']').attr('checked', 'checked');
	    });
	},
	get: function() 
	{
	    var out = [], self = this;
	    $.each(this.config.src,function(i,e){
		if (self.$field.find('input[value='+i+']').is(':checked'))
		    out.push(e.internal);
	    });	    
	    return out;
	},
	remove: function()
	{
	    this.$label.remove();
	    this.$error.remove();
	    this.$field.remove();
	},
	error: function(path,text) 
	{
	    if (path.length > 0) return;
	    this.$error.text(text);	    
	},
	clear: function() 
	{
	    this.$error.text('');
	}
    };

    // Select node ------------------------------------------------------------------

    function node_select(ctx,config) 
    {
	this.id      = gen();
	this.ctx     = ctx;
	this.config  = config;
	this.string  = new node_string(ctx,config);
	this.current = null;
    }

    node_select.prototype = {
	render: function($where) {

	    var self = this, cache = {}, lastXHR;

	    var source = function(request,response) {

		var term = request.term;

		function respond(list) {
		    if (list.length > 10) list.length = 10;
		    cache[term] = list;
		    response(list);
		}

		if (term in cache) {
		    respond(cache[term]);
		    return;
		}
		
		var matcher = new RegExp(
		    '\\b' + term.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"),
		    'i'
		);

		var local = $.grep(self.config.ss || [], function(value){		    
		    return matcher.test(value.value);
		});

		if (typeof self.config.ds == "string") {
		    lastXHR = $.get(self.config.ds,{'complete':term},function(data,status,xhr) {
			if (xhr == lastXHR) respond($.merge(data.list,local));
		    },'json');
		}
		
		else {
		    respond(local);		    
		}
	    };

	    this.string.render($where);
	    this.string.$field.autocomplete({
		minLength: 0,
		source: source,
		select: function(event, ui) {
		    self.apply(ui.item);
		    return false;
		}
	    }).blur(function() {

		if ($(this).val() == '') {
		    self.apply(null);
		    return; 
		}

		self.apply(self.current);

	    }).addClass('joy-select').focus(function(){
		self.$html.hide();
		$(this).css(self.reset).autocomplete("search","");
	    }).data('autocomplete')._renderItem = function(ul,item) {
		return $('<li></li>').data('item.autocomplete',item).append(
		    $('<a></a>').append(item.html ? item.html : item.label).toggleClass('joy-custom',!!item.html)
		).appendTo(ul);
	    };

	    this.$html = $('<div class="joy-select-html"></div>').insertAfter(this.string.$field).hide()
		.click(function(){self.string.$field.focus()});
	    this.reset = {
		position:  this.string.$field.css('position'),
		opacity:   this.string.$field.css('opacity'),
		'z-index': this.string.$field.css('z-index')
	    };
		
	},
	identify: function($where) {
	    this.string.identify($where);
	},
	apply:function(elem) {
	    if (elem == null) {	    
		this.current = null;
		this.string.$field.val('').removeClass('joy-select-set').css(this.reset);
	    }
	    else {
		this.current = elem;
		this.string.$field.val(elem.value).addClass('joy-select-set');
		if (elem.html) {
		    var z = this.$html.html(elem.html).show().css('z-index');
		    if (z == 'auto') z = 1;
		    this.string.$field.css({position:'absolute',opacity:0,'z-index':z+1});
		}
		else {
		    this.$html.hide();
		    this.string.$field.css(this.reset);
		}
	    }
	},
	set: function(value) 
	{
	    var self = this, applied = false, json = $.toJSON(value);

	    function find(list) {		
		$.each(list,function(i,elem){		    
		    if (applied) return;
		    if ($.toJSON(elem.internal) === json) {
			self.apply(elem);			
			applied = true;
		    }
		});
	    }

	    find(this.config.ss || []);
	    if (typeof this.config.ds == "string" && !applied)
		$.get(this.config.ds,{'get':$.toJSON(value)},function(data){find(data.list)},'json');	    
	},
	get: function() 
	{
	    return this.current ? this.current.internal : null;
	},
	remove: function()
	{
	    this.string.remove();
	},
	error: function(path,text) 
	{
	    this.string.error(path,text);   
	},
	clear: function() 
	{
	    this.string.clear();
	}
    };

    // The main function ------------------------------------------------------------

    function joy(id,config,params) 
    {
        var ctx     = this;
	var $hidden = $('#'+id), $form = $hidden.parent();
	var root    = recurse(ctx,config);
	var url     = $form.attr('action');
	var init    = $.parseJSON($hidden.val());	
	root.identify($form);
	root.render($form);
	root.set(init);	

	$form.submit(function(){

	    var data = root.get(), json = $.toJSON(data);
	    $hidden.val(json);

	    $.ajax({
		url:url,
		data:$.toJSON({data:data,params:params || null}),
		type:'POST',
		contentType:'application/json',
		success:function(response){		
		    if (response.data) root.set(response.data);
		    if (response.errors) {
			root.clear();
			$.each(response.errors,function(i,error){
			    root.error(error[0],error[1]);
			});
		    }
		    if (response.code) {
			execute(ctx,$form,response.code);
		    }
		}
	    });

	    return false;
	});
    }

    // Registering nodes ------------------------------------------------------------

    joy.nodes = {
	'html'   : node_html,
	'string' : node_string,
	'select' : node_select,
	'array'  : node_array,
	'choice' : node_choice
    };

    function recurse(ctx,config) {

	if (config == null) return node_empty;

	if ('t' in config) {
	    var constructor = joy.nodes[config.t];
	    return new constructor(ctx,config);
	}

	return new node_concat(ctx,config);
    }

    return joy;

})(jQuery); 