(function(){

    var $;

    function searchText(inwhat,regexp) {
	var matching = [];
	$('body *').each(function() {

	    var $me = $(this), texts = [
		inwhat.text  ? $me.text()        : '',
		inwhat.href  ? $me.attr('href')  : '',
		inwhat.css   ? $me.attr('class') : '',
		inwhat.title ? $me.attr('title') : '',
		inwhat.alt   ? $me.attr('alt')   : ''
	    ];

	    $.each(texts,function(i,e){
		if (regexp.test(e))
		    matching.push(e);
	    });
	});
	return unique(matching);
    }

    function searchElement(regexp) {
	var matching = [];
	$('body *').each(function() {
	    var $me = $(this);
	    if (regexp.test($me.text())
		|| regexp.test($me.attr('href'))
		|| regexp.test($me.attr('class'))
		|| regexp.test($me.attr('title'))
		|| regexp.test($me.attr('alt')))
	    {
		matching.push($me);
	    }
	});
	return matching;
    }

    function extractRss() {
	var matching = searchText({href:true},/rss/i);
	$.each(matching,function(i,e) {
	    if (!/^http/.test(e)) {
		if (e[0] == '/') 
		    matching[i] = document.location.origin + e;
	        else
		    matching[i] = document.location.origin + document.location.pathname.replace(/[^/]*$/,'') + e;
	    }
	});
	return unique(matching);
    }

    function extractEmail() {
	var mailto = map(searchText({href:true},/mailto/i),function(s){ return s.replace(/mailto:/,''); });
	return mailto;
    }

    function extractName() {
	return [ $('head title').text() ];
    }

    function extractAddress() {
	regex = /[^:]{1,29}\s[0-9]{5}\s[^.]{1,29}/;
	function extract(s) {
	    return s.match(regex)[0].trim(); 
	}
	return unique(map(searchText({text:true},regex),extract));
    }

    function extractPhone() {
	regex = /0[1-8][ .]*[0-9]{2}[ .]*[0-9]{2}[ .]*[0-9]{2}[ .]*[0-9]{2}[ .]*/;
	function extract(s) {
	    return s.match(regex)[0].replace(/[^0-9]/g,'');
	}
	return unique(map(searchText({text:true},regex),extract));
    }

    function unique(arr) {
	var out = [], seen = {};
	while (arr.length > 0) {
	    var next = arr.shift();
	    if (seen[next]) continue;
	    seen[next] = true;
	    out.push(next);
	}
	return out;
    }

    function map(arr,func) {
	var out = [];
	$.each(arr,function(i,e){
	    out.push(func(e,i));
	});
	return out;
    }

    function esc(text) {
	return $('<div></div>').text(text).html();
    }

    function act() {

	$ = jQuery;

	$('#runorg-results').remove();

	var extraction = {
	    rss: extractRss(),
	    name: extractName(),
	    email: extractEmail(),
	    address: extractAddress(),
	    phone: extractPhone(),
	    site: [document.location.origin]
	};

	out = ["<table id=runorg-results>"];
	for (var k in extraction) {
	    out.push('<tr><td>',k,'</td><td><ul>');
	    $.each(extraction[k],function(i,e){
		out.push('<li><a title="',k,'" href="#">',esc(e),'</a></li>');
	    });
	    out.push('</tr>');
	}
	out.push('</table>');

	$table = $(out.join(''));
	$('body').append($table);
	$table.css({
	    'position' : 'fixed',
	    'top' : '5px',
	    'right': '5px',
	    'font-size': '10px',
	    'width': 'auto',
	    'border-collapse': 'collapse'
	}).find('td').css({
	    'border': '1px solid #333',
	    'padding': '2px 4px',
	    'backgroundColor': 'white'
	}).find('ul').css({
	    'list-style-type': 'none',
	    'padding': 0,
	    'margin': 0
	}).find('a').click(function(){
	    var $me = $(this), key = $me.attr('title'), value = $me.text();
	    $.get('http://runorg.com/admin/extract/cookie',{key:key,value:value},function(){},'jsonp');
	    $me.remove();
	});

	console.log(extraction);
    }
    
    if (typeof jQuery != 'undefined') act();
    else {
	var b = document.getElementsByTagName('body')[0];
	var s = document.createElement('script');
	s.type   = 'text/javascript';
	s.src    = 'http://runorg.com/public/js/jquery.min.js';
	b.appendChild(s);
	
	function retry() {
	    if (typeof jQuery == 'undefined') 
		return setTimeout(retry,500);
	    act();
	}

	retry()
    }
    
})();