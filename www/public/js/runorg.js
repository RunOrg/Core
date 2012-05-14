var runorg = {

    jQuery : function()
    {
	var args = [].slice.call(arguments,0);
	var sel = $(args.shift());
	var func = sel[args.shift()];
	func.apply(sel,args);
    },

    $: jQuery('body'),

    refreshDelayed : function()
    {
	setTimeout(function(){
	    document.location.reload(true)
	},5000);
    },

    find : function(sel) 
    { 
	return $(sel); 
    },

    assoKey: function(url) {

	var
          $name = this.find('.-asso-name input'),
	  $key = this.find('.-asso-key input'),
          currentXHR;

	function fetch() { 
	    $key.addClass('loading');
	    currentXHR = $.get(url,{value:$(this).val()},function(data,ignore,XHR){
		if (XHR != currentXHR) return;
		$key.removeClass('loading').val(data.value); 
	    },'json');
	}

	$key.change(fetch);
	$name.change(fetch);
    },

    _editJoin : [],

    startEditJoin : function(url)
    {
	var jids = runorg.the_grid.selected(), j = [];

	$.each(jids, function(i,e){
	    j.push({id:e,url:null});
	});

	runorg._editJoin = j;
	
	if (j.length > 0) { 
	    runorg.editJoin(j[0].id, url);
	}
    },

    editJoin : function(jid, url) 
    {
	$.each(runorg._editJoin, function(i,e) {
	    if (e.id == jid) { 
		if (e.url) $.address.value(e.url);
		else $.post(url,{jid:jid},function(data){
		    if (!data.url) runorg.panic();
		    else 
		    { 
			e.url = data.url.replace(/.*#/,''); 			
			$.address.value(e.url); 
		    }
		});
	    }
	});
    },

    editsJoin : function(jid, url, sel)
    {
	var p = null, $s = $('#'+sel);
	$.each(runorg._editJoin, function(i,e) { if (e.id == jid) p = i; });
	if (p === null || runorg._editJoin.length < 2) return;

	$s.find('.total').text(runorg._editJoin.length);
	$s.find('.current').text(p+1);
	
	if (p == 0) 
	    $s.find('.prev').css('visibility','hidden');
	else
	    $s.find('.prev').click(function(){ runorg.editJoin(runorg._editJoin[p-1].id, url); });

	if (p == runorg._editJoin.length - 1) 
	    $s.find('.next').css('visibility','hidden');
	else
	    $s.find('.next').click(function(){ runorg.editJoin(runorg._editJoin[p+1].id, url); });

	$s.show();
    },

    onLoginPage : function(cookie) 
    {
	$(function(){
	    $.address.change(function(event){
		var url = '/#/' + event.pathNames.join('/');
		document.cookie = cookie+'='+url+'; path=/';
	    });
	});
    },

    ping : function(){
	var data = {__:0};
	if (runorg.start.current) data.start = runorg.start.current;
	$.post('/ping',data,function(data){
	    var ping_delay = runorg.start.current ? 10000 : 30000; 
	    setTimeout(runorg.ping,ping_delay);
	    jog.call(runorg,data.code);
	},'json');
    },

    init : function()
    {
	runorg.ping();

	var myassos_die = 0;

	$('#navbar-assos').hover(function(){
	    $('#my-assos').fadeIn();	    
	}, function(){
	    myassos_die = +(new Date()) + 1500;
	    setTimeout(function(){ 
		if (myassos_die < +(new Date()))
		    $('#my-assos').fadeOut(); 
	    },2000);
	});

	$('#my-assos').hover(function(){
	    $(this).fadeIn();
	    myassos_die = +(new Date()) + 10000;
	},function(){
	    $(this).fadeOut();
	}).click(function(){ $(this).hide(); });

	if ($('#my-assos a').length == 0) $('#my-assos').remove();
    },

    wait : function(url,code)
    {
	var self = this;

	(function recurse(){
	    setTimeout(function(){
		$.get(url,{}, function(data){
		    if (data.ok) jog.call(self,code);
		    else recurse(); 
		},'json');
	    }, 5000);
	})();
    },

    wallPost : function(id,html,code)
    {
	var $n = $('#'+id);
	$n.prev().find('textarea').val('').blur();
	$n.find('.empty-list').remove();
	$n.prepend(html);
	jog.call(jog.extend(this,$n),code);
    },

    autocomplete : function(id,idto,url)
    {
	$('#'+id).autocomplete({
	    minLength:1,
	    source:function(request,response){
		$.get(url,{term:request.term},function(data){
		    response(data.val)
		},'json');
            },
	    select:function(event,ui) {
		$('#'+idto).val(ui.item.payload);
		$('#'+id).val(ui.item.label);
	    }	    	
	}).blur(function(){
	    var v = $('#'+idto).val();
	    if (v) {
		$(this).val(eval('('+v+')')[1]).addClass('filled');
	    }	    
	}).focus(function(){
	    $(this).removeClass('filled').val('');
	}).data('autocomplete')._renderItem = function(ul,item) {
	    return $(item.html)
		.data('item.autocomplete',item)
		.appendTo(ul);
	};
    },

    appendReply : function(id,html,code)
    {
	jog.call(jog.extend(this,$('#'+id+' > .-body').append(html).find('.comment:last')), code);	
    },

    _uiDelay : false,

    uiDelay : function(f) 
    {
	if (runorg._uiDelay) return;
	f();
	runorg._uiDelay = true;
	setTimeout(function() { runorg._uiDelay = false }, 500);
    },

    like : function(url)
    {
	var $t = $(this); 
	runorg.uiDelay(function(){
	    var unlike = $t.hasClass('-liked'), v = $t.children('span').text();
	    $t.toggleClass('-liked', !unlike);
	    $t.children('span').text(parseInt(v,10) + (unlike ? -1 : 1)); 
	    $.post(url,{like:unlike ? 0 : 1},function(){},'json');
	});
    },

    fetchMore : function(url,args)
    {	
	var $s = $(this).css('visibility','hidden');
	$.get(url,args,function(data){
	    var $i = $(data.html).insertBefore($s);
	    jog.call($i,data.code);
	    $s.remove();
	},'json');    
	return false;
    },
   
    _keyCache : {},

    sortable : function(id,idto,placeholder)
    {
	$('#'+id).sortable({
	    placeholder: placeholder,
	    start: function(e,ui) {
		if ($('#'+id).is('tbody')) {
		    var cols = 0;
		    $('tbody').closest('table').find('thead tr:first td').each(function(){
			cols += parseInt($(this).attr('colspan') || '1',10);
		    });
		    ui.placeholder.html('<td colspan="'+cols+'">&nbsp;</td>');
		}
	    },
	    stop: function() {		
		if (idto)
		    $('#'+idto).val('["'+$('#'+id).sortable('toArray').join('","')+'"]');
	    }
	});
    },

    _triggers : {},
    
    setTrigger : function(name,code)
    {
	runorg._triggers[name] = [this,code];
    },

    runTrigger : function(name)
    {
	if (name in runorg._triggers) 
	    jog.call(runorg._triggers[name][0],runorg._triggers[name][1]);
    },

    removeParent : function(sel)
    {
	$(this).closest(sel).remove();
    },

    toggleParent : function(id,sel,cls) 
    {
	$('#'+id).focus(function() {
	    toggle(this,false);
	}).blur(function() {
	    toggle(this,!$(this).val().match(/\S/));
	}).blur();

	function toggle(what,hide) {
	    $(what).closest(sel).toggleClass(cls,hide);
	}
    },

    panic : function()
    {
	window.location.reload();
    },

    refresh : function()
    {
	window.location.reload();
    },

    sendList : function(id,url)
    {
	var self = this, data = [];

	$('#'+id+' input[type="hidden"][name="data"]').each(function(){
	    data.push(eval('('+($(this).val() || 'null')+')'));
	});
	
	var sentJson = $.toJSON(data);

	$.post(url,{data:sentJson},function(data){
	    if ('code' in data) jog.call(self,data.code);
	},'json');
    },

    appendList : function(id,html,code)
    {
	jog.call($(html).appendTo('#'+id),code);
    },

    appendUniqueList : function(id,html,code,unique) 
    {
	var $u = $('#'+unique);
	if($u.length > 0) 
	    runorg.replaceInList(unique,html,code);
	else
	    runorg.appendList(id,html,code);
    },

    replaceInList : function(id,html,code)
    {
	var $i = $('#'+id), $h = $(html).insertAfter($i);
	$i.remove();
	jog.call($h,code);
    },

    sendSelected : function(url)
    {
	var self = this;
	if (runorg.the_grid)
	{
	    var selected = '["' + runorg.the_grid.selected().join('","') + '"]';
	    $.post(url,{selected:selected},function(data){
		if ('code' in data) jog.call(self,data.code);
	    },'json');
	}
    },

    grid : function(id,url,cols,editurl)
    {
        runorg._keyCache[url] = runorg._keyCache[url] || {};

        var self      = this,
        grid      = new carrelage('#'+id),
        connector = {
            key:function(str,async) {
                var r = {key:{'':'0::::0:a'},data:{}};
                if (!str) return r;
                var pair = str.split(':');
                if (pair[0] == 0) r.key[str] = '0::::'+pair[1]+':'+(pair[2] || 'a');
                return r;
	    },
            data:function(key,async) {
                var k = key.split(':');
                $.get(url,{p:unescape(k[1]),i:k[2],d:k[3],s:k[4],o:k[5]},function(r){
		    var key = k.join(':');
                    if (r.code) jog.call(self,r.code);                

		    var ret = {key:{},data:{}};

		    ret.data[key] = r.rows || [];

		    if (r.next) {
			var pge = parseInt(k[0],10),
			    key = [pge+1,k[4],k[5]].join(':'),
        		    val = [pge+1,escape(r.next[0]),r.next[1],r.next[2] ? 'd' : 0,k[4],k[5]].join(':');
			ret.key[key] = val;
		    }

		    async(ret);
                });
            }
        },
        cache     = new carrelage.pager.keyCache(connector,runorg._keyCache[url]),
        pager     = new carrelage.pager(grid,cache);

	runorg.the_grid = grid;

	var addr = $.address.path();

	pager.register('fail',function(){
	    $.address.value(addr);
	});

	pager.register('prerender',function(arg){

	    var head = [], 
                segs = (arg.page || '').split(':'), 
	        page = parseInt(segs[0],10) || 0, 
                sort = segs[1] || 0, 
                ord  = segs[2] || 'a';	  
    
	    $.each(cols,function(i,c){
		var n = ('n' in c) ? c.n : '&emsp;' ;		    
		if ('s' in c) {			
		    head.push(['<a class="',
			       i == sort ? 'ord-' + ord : 'ord-n',
			       '" href="#',
			       addr,
			       '?p=0:',
			       i,
			       ':',				   
			       (i != sort || ord != 'a') ? 'a' : 'd',
			       '"><span style=\"width:',
			       c.w - 15,
			       "px\">",
			       n,
			       '</span></a>'].join(''));				  
		}
		else {
		    head.push('<span>'+n+'</span>');
		}
	    });
	    
	    grid.headings(head);
	    
	    var $f = grid.foot().html(
		['<a class="prev" style="visibility:hidden">&laquo;&ensp;',
		 page,
		 '</a><span>&ensp;',
		 page+1,
		 '&ensp;</span><a class="next" style="visibility:hidden">',
		 page+2,
		 '&ensp;&raquo;</a>'].join('')).addClass('paging');
		    
	    function showNext(b)
	    {
		if (b) 
		    $f.children('.next').attr({href:'#'+addr+'?p='+n,style:''});	    
	    }
		
	    function showPrev(b)
	    {
		if (b)
		    $f.children('.prev').attr({href:'#'+addr+'?p='+p,style:''});
	    }	    
	    
	    var n = [page+1,sort,ord].join(':'), p = [page-1,sort,ord].join(':');

	    if (pager.exists(n,showNext)) showNext(true);
	    if (pager.exists(p,showPrev)) showPrev(true);	    
	});

	var XHR;
	grid.edit = function(jid) {
	    XHR = $.get(editurl,{jid:jid},function(data,status,xhr) {
		if (xhr != XHR) return;
		if ('url' in data) document.location = data.url ;
	    },'json');
	};

        grid.columns(cols);
	jog.paramListen('p',function(v){ 
	    if ($('#'+id).is(':visible')) {
		pager.show(v || '');
	    }
	});
    },

    joinGrid : function(id,url,cols,edit)
    {
        runorg._keyCache[url] = runorg._keyCache[url] || {};

        var self      = this,
        grid      = new carrelage('#'+id),
        connector = {
            key:function(str,async) {
                var r = {key:{'':'0::::0:a'},data:{}};
                if (!str) return r;
                var pair = str.split(':');
                if (pair[0] == 0) r.key[str] = '0::::'+pair[1]+':'+(pair[2] || 'a');
                return r;
	    },
            data:function(key,async) {
                var k = key.split(':');
                $.get(url,{p:unescape(k[1]),i:k[2],d:k[3],s:k[4],o:k[5]},function(r){
		    var key = k.join(':');
                    if (r.code) jog.call(self,r.code);                

		    var ret = {key:{},data:{}};

		    ret.data[key] = r.rows || [];

		    if (r.next) {
			var pge = parseInt(k[0],10),
			    key = [pge+1,k[4],k[5]].join(':'),
        		    val = [pge+1,escape(r.next[0]),r.next[1],r.next[2] ? 'd' : 0,k[4],k[5]].join(':');
			ret.key[key] = val;
		    }

		    async(ret);
                });
            }
        },
        cache     = new carrelage.pager.keyCache(connector,runorg._keyCache[url]),
        pager     = new carrelage.pager(grid,cache);

	runorg.the_grid = grid;

	var addr = $.address.path();

	pager.register('fail',function(){
	    $.address.value(addr);
	});

	pager.register('prerender',function(arg){

	    var head = [], 
                segs = (arg.page || '').split(':'), 
	        page = parseInt(segs[0],10) || 0, 
                sort = segs[1] || 0, 
                ord  = segs[2] || 'a';	  
    
	    $.each(cols,function(i,c){
		var n = ('n' in c) ? c.n : '&emsp;' ;		    
		if ('s' in c) {			
		    head.push(['<a class="',
			       i == sort ? 'ord-' + ord : 'ord-n',
			       '" href="#',
			       addr,
			       '?p=0:',
			       i,
			       ':',				   
			       (i != sort || ord != 'a') ? 'a' : 'd',
			       '"><span style=\"width:',
			       c.w - 15,
			       "px\">",
			       n,
			       '</span></a>'].join(''));				  
		}
		else {
		    head.push('<span>'+n+'</span>');
		}
	    });
	    
	    grid.headings(head);
	    
	    var $f = grid.foot().html(
		['<a class="prev" style="visibility:hidden">&laquo;&ensp;',
		 page,
		 '</a><span>&ensp;',
		 page+1,
		 '&ensp;</span><a class="next" style="visibility:hidden">',
		 page+2,
		 '&ensp;&raquo;</a>'].join('')).addClass('paging');
		    
	    function showNext(b)
	    {
		if (b) 
		    $f.children('.next').attr({href:'#'+addr+'?p='+n,style:''});	    
	    }
		
	    function showPrev(b)
	    {
		if (b)
		    $f.children('.prev').attr({href:'#'+addr+'?p='+p,style:''});
	    }	    
	    
	    var n = [page+1,sort,ord].join(':'), p = [page-1,sort,ord].join(':');

	    if (pager.exists(n,showNext)) showNext(true);
	    if (pager.exists(p,showPrev)) showPrev(true);	    
	});

	grid.edit = edit; 
        grid.columns(cols);

	jog.paramListen('p',function(v){ 
	    if ($('#'+id).is(':visible')) {
		pager.show(v || '');
	    }
	});
    },

    lazyPick : function(url,sel) 
    {
	var $t = $(this), $n = $(sel), nv = $n.is(':visible');

	$t.toggleClass('open',!nv);
	$n.toggle(!nv);

	if (!nv && $n.children().length == 0 && !$t.is('.loading'))
	{
	    $t.addClass('loading');
	    $.get(url,{},function(data){
		if ('html' in data) {
		    var code = 'code' in data ? data.code : []; 
		    jog.call(jog.extend({},$(data.html).appendTo($n)),data.code);
		}
		$t.removeClass('loading');
	    });
	}
    },

    lazyNext : function(url)
    {
	runorg.lazyPick.call(this,url,$(this).next());
    },

    notify : function(id,unread,total) 
    {
	$('#'+id)
            .toggleClass('navbar-notif-hide',total == 0)
            .text(total)
	    .css({backgroundColor:unread>0?'orange':'white'});
    },
    
    redirect : function(where)
    {
	document.location = where;
    },
    
    setField : function(id, value, overwrite)
    {
	var $field = $('#'+id);

	function set(value) 
	{
	   $field.val(value);
	}

	if (overwrite || $field.val() == '') 
	{
	    if ($.isArray(value)) runorg.readFrom(value, set);
	    else set(value);
	}
    },

    verticalPicker : function(id) 
    {
	$('#'+id).change(function(){
	    var v = $(this).val();
	    if (v) {
		v = eval('('+v+')');
		$(this).next().find('a').text(v[1]);
	    }	   
	});
    },

    readFrom : function(code, set) 
    {
	var f = eval('('+code[0]+')');
	f.apply(this,code.slice(1))(function(data){ set(data.val); });
    },

    onChange : function(sel, code)
    {
	var self = this;
	this.$.find(sel).change(function()
        {
	    jog.call(self,code);
	});
    },

    askServer : function(url, extract, data)
    {
	var self = this;
        for (var k in extract) data[k] = $('#'+extract[k]).val();
	
	return function (process) {
	    $.post(url, $.extend({__:0},data), process, 'json');
	}
    },

    moreReplies : function(url)
    {
	var $s = $(this).css('visibility','hidden');
	$.get(url,{},function(data){
	    $s.parent().find('.comment').remove();
	    var $i = $(data.html).insertBefore($s);
	    jog.call($i,data.code);
	    $s.remove();	    
	},'json');    
	return false;
    },

    assignPicked : function (from,to) 
    {
	var t = $('#'+from+' .picked .-value').text();
	if (t) $('#'+to).val(t).change();
    },

    sendPicked : function(from,to)
    {
	var t = $('#'+from+' .picked .-value').text();
	if (t) 
	{
	    var self = $(this);
	    $.post(to,{picked:t},function(data){
		jog.call(self,data.code);
	    },'json');
	}
    },

    picker : function(id)
    {
	$('#'+id).click(function(e){
            var $t = $(e.target).closest('a');
	    $(this).children('.picked').removeClass('picked');
	    $t.addClass('picked');
	});		
    },

    replaceWith : function(sel,html,code)
    {	
	var $c = ('$' in this ? this.$ : $(this)).closest(sel), $n = $(html);
	$c.after($n).remove();
	jog.call(jog.extend(runorg,$n),code);
    },

    replaceOtherWith : function(sel,html,code)
    {	
	var $c = $(sel), $n = $(html);
	$c.after($n).remove();
	jog.call(jog.extend(this,$n),code);
    },

    runFromServer : function(url,args,disable)
    {
	var $s = $(this);
	if (disable) $s.button({disabled:true});
	$.post(url,$.extend({__:0},args || {}),function(data){
	    if (disable) $s.attr({disabled:false});
	    jog.call($s,data.code);
	},'json');
    },

    onClick : function(sel,code)
    {
	var self = this;
	var $clickable = this.$.find(sel);
	$clickable.click(function()
        {
	    jog.call(self,code);
	});
    },

    hideLabel : function(id)
    {	
	var $labl = this.$.find('label[for='+id+'].label');

	$('#'+id).focus(function() {
	    $labl.hide();
	}).blur(function() {
	    $labl.toggle(! $(this).val().match(/\S/));
	}).blur();
    },

    openClose : function()
    {
	var $p = $(this).parent();

	if (!$p.hasClass('open')) {
	    
	    var close = function()
	    {
		$p.removeClass('open');
		$('body').unbind('click',close);
	    };
	    
	    $p.addClass('open');

	    setTimeout(function(){ $('body').bind('click',close); }, 500);
	}

    },

    _profiling:null,

    showProfile : function(key,html) {

	if (top.location != self.location) return;

	if (runorg._profiling === null) {
	    runorg._profiling = {};
	    $('<div id="profiling" class="margin:20px auto;width:960px"/>').appendTo('body');
	}

	$('#profiling').accordion('destroy');

	if ((key in runorg._profiling)) 
	    runorg._profiling[key].remove();

	runorg._profiling[key] =
	    $('<h3><a href="javascript:void(0)">'+key+'</a></h3><div>'+html+'</div>')
	    .prependTo('#profiling');

	$('#profiling').accordion();
    }
};
