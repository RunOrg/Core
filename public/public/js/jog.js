var jog = {

    $ : jQuery('body'),
    
    staticInit : function() {},
    
    _paramListen : [],
    
    paramListen : function(name,func)
    {
	var a = jog._paramListen;	
	a.push({n:name,f:func});
	if (a.length > 5) a.shift();
    },
    
    _reloadListen : [],
    
    reloadListen : function(func)
    {
	var a = jog._reloadListen;	
	a.push(func);
	if (a.length > 5) a.shift();
    },
    
    _last : [],

    boxRefresh : function(delay)
    {
	setTimeout(function(){
	    jog._last = ["-------"];
	    $.address.update();	
	},delay);
    },

    boxInvalidate : function()
    {
	jog._last = ["-------"];
    },

    boxLoad : function(what)
    {
	jog._last = ["-------"];
	if (document.location == what) 
	    $.address.update();
	else  
	    document.location = what;
    },
    
    init : function(url)
    {
	var split   = url.split('#'), ajax = split[0], dflt = split[1] || '';
	var loading = 0; 

	if (ajax[ajax.length-1] != '/') ajax += '/';

	$(function(){
	    $.address.change(function(event){
		function filter(arr) {
                    var out = [];
		    $.each(arr,function(i,e){ if (e) out.push(e); });
		    return out;					      
                }
		if (event.pathNames.length == 0) request(filter(dflt.split('/')),event.parameters);
		else request(event.pathNames,event.parameters);		
	    });
	});

	function request(path, params)
	{
	    if (jog._last.join('/') == path.join('/')) { finish(); return; }

	    var same = [], my_loading = ++loading;

	    $.each(path, function(i,e) { if (jog._last.length > i && jog._last[i] == e) same.push(i); });
	    var json_same = (same.length == 0) ? {same:"[]"} : {same:$.toJSON(same)};
	    $.post(ajax + path.join('/'), json_same, receive, 'json');

	    function receive(data)
	    {
		if (my_loading != loading) return;		
		jog._last = path;
		jog.call(jog,data.code);
		finish();
	    }

	    function finish()
	    {
		$.each(jog._reloadListen,function(i,l){
		    l();
		}); 

		$.each(jog._paramListen,function(i,l){
		    if (l.n in params) l.f(params[l.n]);
		    else l.f('');
		});
	    }
	}
    },

    getBox : function(name)
    {
	var path = name.split('.');
	var box  = jog.box = jog.box || {};

	$.each(path,function(i,e)
	{
	    box[e] = box[e] || {};
	    box = box[e];
	});

	return box;
    },

    defineBox : function(name,id)
    {
	box = jog.getBox(name);

	for (var k in box) delete box[k];

	box.$self = $('#'+id);
    },

    fillBox : function(name,html,code)
    {
	box = jog.getBox(name);
	
	for (var k in box) if (k != '$self') delete box[k];
	
	box.$self.html(html);
	jog.call({$:box.$self},code);
    },

    disable : function($what)
    {
	$what.each(function()
        {
	    $(this).attr('disabled','disabled');
	    
	    if ($(this).hasClass('pretty-button'))
		$(this).addClass('ui-button-disabled ui-state-disabled');
	});
	
	return $what;
    },
    
    enable : function($what)
    {
	$what.each(function()
        {
	    $(this).removeAttr('disabled');
	    
	    if ($(this).hasClass('pretty-button'))
		$(this).removeClass('ui-button-disabled ui-state-disabled');
	});

	return $what;
    },

    remote : function(self,url,args,finish) 
    {
	$.post(url,$.extend({__:0},args || {}),function(data){
	    if ('html' in data) self.$.html(data.html);
	    if ('code' in data) jog.call(self,data.code);
            if (finish) finish.call(self,data)
        },'json');
    },


    post: function(url,data,finish)
    {
	var self = this;
	$.ajax({
	    url:url,
	    data:$.toJSON(data),
	    type:'POST',
	    contentType:'application/json',
	    success:function(response){		
		if (response.code) jog.call(self,response.code);
		if (finish) finish.call(self,response);		
	    }
	});
    },

    extend : function(self,$html) 
    {
	function f() {
	    this.$ = $html;
        }
        f.prototype = self;
	return new f();
    },

    delay : function(time,code) {
	var self = this;
	setTimeout(function(){ jog.call(self,code); }, time);
    },

    call : function(self,code)
    {
	$.each(code,function(i,e)
	{
	    var f = eval('('+e[0]+')');
	    f.apply(self,e.slice(1));
	}); 
    },

    form : function (id, fields, data)
    {
	var $form = $('#' + id), $disabled = null, self = this;
	jog.enable($form.find('button[type=submit]'));
	$form.submit(onSubmit);
	parseData(data);

	function onSubmit() 	
	{
	    var sent = [];
	    for (var id in fields)
	    {  
		function process(value) {
		    if ( 'json' in fields[id] ) value = eval('('+(value || 'null')+')');
		    return value;
		}

		var $field = $('#'+id), value = null;
		
		if ($field.is(':checkbox.multi'))
		{
		    value = [];
		    $(':checkbox[name='+$field.attr('name')+']:checked').each(function(){
			value.push(process($(this).val()));
		    });
		}		    
		else if ($field.is(':checkbox'))
		    value = process($field.is(':checked'));
		else if ($field.is(':radio'))
		    value = process($(':radio[name='+$field.attr('name')+']:checked').val());
		else
		    value = process($field.val());
		
		sent.push([ fields[id].n, value ]);
	    }

	    var sent_json = $.toJSON(sent);
	    
	    $disabled = jog.disable($form.find('button[type=submit]'));
	    $.post( $form.attr('action'), { data: sent_json }, onResponse, 'json');
	    return false;
	}

	function onResponse(data) 
	{
	    if ($disabled) jog.enable($disabled);
	    if ('form' in data) { parseData(data.form); }
	    if ('code' in data) { jog.call(jog.extend(self,$form),data.code); }
	}
	
        function parseData(data)
        {
            for (var id in data.values)
            {
                var $i = $('#'+id), v = data.values[id];

                if ( id in fields && 'json' in fields[id] ) v = $.toJSON(v);

		if ($i.is(':checkbox.multi'))
		{
		    v = v || [];
		    $(':checkbox[name="'+$i.attr('name')+'"]"').attr('checked',false);
		    for (var k in v) 
			$(':checkbox[name="'+$i.attr('name')+'"][value=\''+(v[k] || '')+'\']').attr('checked',true);
		}
                else if ($i.is(':checkbox')) 
                    $i.attr('checked',!!v);                
                else if ($i.is(':radio')) 
                    $(':radio[name="'+$i.attr('name')+'"][value=\''+(v || '')+'\']').attr('checked',true);                
                else 
                    $i.val(v || '').change().blur();                
            }

	    $form.find('label.field-error').each(function()
            {
		var id = $(this).attr('for');
		if (id in data.errors) 
		    $(this).text(data.errors[id]).show();
		else
		    $(this).hide();
	    });	    
	}
    }    
};
   
jog.staticInit = function() {};
this.find = jog.find;