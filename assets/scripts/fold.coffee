@foldAccents = (str) ->
  for r in foldAccents.a
    str = str.replace(r[0],r[1])
  return str.trim().toLowerCase()  

@foldAccents.a = [ 
  [ /à|À|â|Â|ä|Ä/g     , 'a' ],
  [ /é|É|ê|Ê|è|È|ë|Ë/g , 'e' ],
  [ /ç|Ç/g             , "c" ],
  [ /î|Î|ï|Ï/g         , "i" ],
  [ /ù|Ù|û|Û|ü|Ü/g     , "u" ],
  [ /ô|Ô|ö|Ö/g         , "o" ],
  [ /œ|Œ/g             , "oe" ],
  [ /[^a-zA-Z0-9]+/g   , " " ]
]        
             