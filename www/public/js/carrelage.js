var carrelage = (function($){
    function c(sel) { this.$ = $(sel) ; this._s = {} }
    c.prototype ={
        _rc : '',
        _ri : '',	
	_h  : 10,
        render : function() 
	{
            var _ = this;

            if (_._o) $('.carrelage tbody',_.$).html(_._ri)
            else {
                var $f = _.foot().detach(); 
                _.$.html(["<table class='carrelage'><thead><tr>",
                          _._rc,
                          "</tr></thead><tbody>",
                          _._ri,
                          "</tbody><tfoot><tr/></tfoot></table>"].join(''));
                $("tfoot tr:last", _.$).append($f.attr('colspan',_._nc));
            }


	    $('.carrelage td.fst input[type="checkbox"]',_.$).change(function(){
		var n = $(this).attr('name').substr(2), c = $(this).is(':checked');
		if (c) _._s[n] = true;
		else delete _._s[n];		
	    });

            _._o = true; return _;
        },
	edit : "",
	selected : function() {
	    var a = [];
	    for (var k in this._s) a.push(k);
	    return a;
	},
        foot : function() 
	{
            var _ = this;
            if (!_._$f) {
                _._$f = $('tfoot tr:last td',_.$);
                if (_._$f.length == 0) _._$f = $('<td/>');
            }
            return _._$f;
        },
	headings : function(array)
	{
	    this._o = false;
	    this._rc = '<td></td><td></td><td>'+array.join('</td><td>')+'</td>';
	},
        columns : function(cols) 
	{
            var b = ["line = function(a,l){a.push(["],
	        e = "].join(''))}",
	        a = [],
	        _ = this,
   	        ed = "'" + _.edit + (_.edit[_.edit.length-1] == '/' ? '' : '/') + "'";

	    a.push("'<td class=\"fst\"><input type=\"checkbox\" name=\"s-'",
		   'l[0]',
		   "'\"'",
		   "l[0] in this._s ? ' checked=\"checked\"' : ''",
		   "'/></td>'");
	    a.push("'<td><a class=\"-edit\" href=\"'",ed,"l[0]","'\"></a></td>'");
            $.each(cols,function(i,c) {
                var p = [ '<td><div',
                          'w' in c ? ' style="width:'+c.w+'px"' : '',
                          'c' in c ? ' class="'+c.c+'"' : '',
                          '>' ];
                var idx = ('i' in c) ? c.i : i;
                a.push("'"+p.join('')+"'",
                       'f' in c ? 'this.line['+i+']('+idx+',l)' : 'l['+idx+']',
                       "'</div></td>'");
            });
            var line;
	    eval(b + a.join(",") + e);
            $.each(cols,function(i,c){ if ('f' in c) line[i] = c.f; });
            _._nc  = cols.length+2;
            _._o = false;
            _.line = line;
            if (_._b) _.body(_._b);
            return _;
        },
        line : function(a,l) {},
        body : function(b)
	{            
            var a = [], _ = this;
            _._b = b;
            $.each(b,function(i,l){
		a.push('<tr class="',i == 0 ? 'fst odd' : i % 2 == 0 ? 'odd' : 'even','">');
		_.line(a,l);
		a.push('</tr>')
	    });
	    if (b.length < _._h) {
		a.push('<tr',b.length == 0 ? ' class="fst"' : '','><td class="fst" colspan="',
		       _._nc,'" style="height:',(_._h - b.length) * 25,'px"></td></tr>');
	    }
            this._ri = a.join('');
            return _;
        }
    };
    return c;
})(jQuery);

carrelage.pager = (function($){
    function c(grid,connect) 
    { 
	var _ = this;
	_._i = 0;
	_._g = grid;
	_._c = connect;
	_._e = {};
    }
    c.prototype = {
	show:function(page) 
	{
	    var _ = this, iter = ++ _._i, key = _._c.key(page,with_key);
	    if (key) return with_key(key);
	    _.trigger('wait',{page:page});

	    function with_key(r)
	    {
		if (iter != _._i) return;

		var key  = r.key[page];
		if (!key) return _.trigger('fail',{page:page});
		
		var data = _._c.data(key,with_data);
		if (data) return with_data(data);
		_.trigger('wait',{page:page,key:key});

		function with_data(r)
		{
		    if (iter != _._i) return;
		    
		    var data = r.data[key];
		    if (!data) return _.show(_._d);
		    
		    _.trigger('prerender',{page:page,key:key,data:data});
		    _._g.body(data).render();
		    _.trigger('postrender',{page:page,key:key,data:data});
		}		
	    }
	},
	exists:function(page,async)
	{
	    var _ = this, key = _._c.key(page,with_key);
	    if (key) { async = false; return with_key(key); }
	    
	    function with_key(r)
	    {		
		var exists = (page in r.key);
		if (async) async(exists); 
		else return exists;
	    }
	},
	register:function(event,listen)
	{
	    var _ = this;
	    if (!(event in _._e)) _._e[event] = [];
	    _._e[event].push(listen);
	},
	trigger:function(event,arg) 
	{
	    var _ = this;
	    if (event in _._e) $.each(_._e[event],function(i,listen){ listen(arg) });
	}
    };
    return c;
})(jQuery);

carrelage.pager.keyCache = (function($){
    function c(connect,store) 
    {
	var _ = this;
	if (!store) store = {};
	_._s = store;
	_._c = connect;
    }
    c.prototype = {
	store:function(r) {
	    for (var page in r.key) { this._s[page] = r.key[page] }
	    return r;
	},
	key:function(page,async)
	{
	    var _ = this;
	    if (page in _._s) 
	    { 
		var r = {key:{},data:{}}; 
		r.key[page] = _._s[page]; 
		return r;
	    }

	    var key = _._c.key(page,with_key);
	    if (key) return _.store(key);

	    function with_key(r) { var r = async(_.store(r)) }
	},
	data:function(key,async) 
	{
	    var _ = this, data = _._c.data(key,with_data);
	    if (data) return _.store(data);

	    function with_data(r) { async(_.store(r)) }
	}
    };
    return c;
})(jQuery);