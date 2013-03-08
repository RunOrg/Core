@analytics = (account, domain) ->
  @_gaq = [['_setAccount',account],['_setDomainName',domain],['_trackPageview']]
  ga = document.createElement 'script'
  ga.type  = 'text/javascript'
  ga.async = true
  ga.src   = 'http://www.google-analytics.com/ga.js'
  s = document.getElementsByTagName('script')[0]
  s.parentNode.insertBefore ga, s
