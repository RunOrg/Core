@do_export = ($b,url) ->
  $b.click -> 
    $p = $ "<span class='progress'><span/></span>"
    $b.hide().before($p)
    to_endpoint url, null, (r) ->
      if !r.url 
        $p.remove()
        $b.show() 
        return call r.code
      check = () ->
        to_endpoint r.url, null, (r) ->
          return call r.code if !("progress" of r)
          progress($p,r.progress)
          if !r.url 
            setTimeout(check, 500) 
            return call r.code
          $i = $ "<iframe style='display:none'/>"
          $b.before($i)
          $i.attr("src",r.url)
      do check 
      call r.code
           

          
      
