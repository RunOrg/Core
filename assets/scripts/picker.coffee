# All static data is made up of three parts
#  - A JSON key which is the actual data handled by the server
#  - A search key (made of space-separated words), used for local search
#  - A piece of HTML to be displayed

# Dynamic data is fetched from the server in two different ways : 
#  - By JSON key (give me the objects with keys [a, b, c, d])
#  - By prefix (give me N objects with names starting with XYZ)
# Returned objects contain two parts : 
#  - The JSON key
#  - A piece of HTML to be displayed


class Picker
  constructor: ($where) ->
 
    # The on-screen rendering of lists
    @$pickable = $where.find "div.-l"
    @$field    = $where.find "div.-f input.-s"
    @$picked   = $where.find "div.-f"

    # the maximum number of pickable items (zero for no maximum)
    @maxPickable = 5

    # the maximum number of picked items (zero for no maximum)
    @maxPicked = 0

    # is the next focus event sent internally ? 
    @isFocusInternal = false 

    # normalized search query being displayed
    @displayedQuery = null  

    # current list of pickable elements
    @pickable = []

    # index of selected pickable element
    @selectedPickable = 0

    # search identifier (incremented when a search starts)
    @searchID = 0

    # static data source (as {json:,key:,html:})
    @static = []

    # dynamic data source 
    @dynamic = null

    # current list of picked items
    @picked = []

    # This function is called when the list of picked items changes
    @onSave = () ->

    # Set up event handling -----------------------------------------------------------------------------------
    
    # Clicking on a pickable element pick it
    @$pickable.mousedown (e) =>
      $e = $ e.target
      return if $e.is(@$pickable)
      sel = $e.closest(".-i").prevAll().length
      @pick()
    
    # Clicking on the "x" of a picked element unpicks it
    @$picked.mousedown (e) =>
      $e = $ e.target
      if $e.is("a.-d") && $e.parent().parent().is(@$picked)
        @unpick $e.parent().prevAll().length
        e.stopPropagation() 

    # Clicking the pickable list focuses the field
    @$picked.click () =>
      @$field.focus() 

    # Focusing the field refills the pickable list
    @$field.focus () =>
      @buildPickable @isFocusInternal
      @isFocusInternal = false
      @$pickable.addClass "-show"     

    # Detect critical keys when they are pressed in the field
    @$field.keydown (e) =>
      switch e.which
 
        # On 'enter', prevent form submission and select
        when 13 
          e.stopPropagation() 
          @pick()

        # On 'backspace', unpick last element
        when 8 
          if @$field.val() == ""
            @unpick()

        # "Up" key moves selection up
        when 40 then @select 1

        # "Down" key moves selection down
        when 38 then @select(-1)

        # "Right" key refills selection block
        when 39 then @buildPickable true

        else
          return true

      return false

    # Detect other keypresses and rebuild pickable list
    @$field.keyup () =>
      @buildPickable()

    # Blurring the field blasts the current query
    @$field.blur () =>
      @$field.val ""
      @$pickable.removeClass "-show"
            
  # ===========================================================================================================
  # determines if two keys are equal
  eq: (a,b) ->
    return if typeof a == "string" then a == b else a.toString() == b.toString()

  # ===========================================================================================================
  # determines if a name matches a provided pattern 
  # (used as part of static element matching)
  matches: (patt, name) ->
    patts = patt.split " "
    names = foldAccents(name).split " "
    for patt in patts
      continue if !patt
      m = false
      for name in names
        continue if name.length < patt.length
        if patt = name.substr 0, patt.length
          m = true
          break
      return false if !m
    return true

  # =========================================================================================================== 
  # query several sources for data (sources are provided as async functions)
  query: (query,fs) ->
    sID = ++@searchID
    @pickable = []
    @$pickable.html "" 
    
    # how many items were loaded ? 
    loaded = 0
    
    # the HTML of the pickable list
    html = []

    # Query all sources...
    for f in fs
      f (items) =>
        
        # Abort if search is cancelled
        return if sID != @searchID
   
        # Push all the items to the result list
        for item in items

          # Don't exceed max items
          break if @maxPickable > 0 && @pickable.length > @maxPickable

          # Do not display that have been picked
          exists = false
          for it2 in @picked
            if @eq it2.json, item.json 
              exists = true
              break
          continue if exists

          # Do not display elements that are already pickable
          for it2 in @pickable
            if @eq it2.json, item.json 
              exists = true
              break
          continue if exists

          @pickable.push item
          html.push "<div class=-i>", item.html, "</div>"

        # If all queries have returned and there are pickable items...
        if ++loaded == fs.length && @pickable.length > 0
          @displayedQuery = query
          @$pickable.html(html.join "").addClass "-full"
          @select(-@selectedPickable)

  # ===========================================================================================================
  # Static data store queries 
  fromStatic: (src) ->
    (next) => 
      results = []
      if @static.length > 0 
        src = foldAccents(src) 
        for it in @static  
          if @matches src, it.key
            results.push it
      next results
                
  # ===========================================================================================================
  # Dynamic data store queries
  fromDynamic: (src) ->
    (next) =>
      return next([]) if !@dynamic
      to_endpoint @dynamic, src, (data) ->
        next(if "list" of data then data.list else []) 

  # ==========================================================================================================
  # Build pickable list from current search field
  # If "force" : rebuild even if no text was entered
  buildPickable: (force) ->   
    force = force || false
    query = @$field.val().trim()
    
    # Don't repeat searches 
    return if query == @displayedQuery
     
    # Blast everything ! 
    @displayedQuery = null
    @$pickable.removeClass "-full"
    @pickable = []

    # Don't search if at least one suggestion and no text
    return if !force && @picked.length > 0 && @$field.val() == ""

    # Run the queries
    @query query, [ @fromStatic(query), @fromDynamic(query) ]

  # =========================================================================================================
  # Render a picked item
  render: (item) ->
    return "<div><a class=-d>&times;</a><span>" + item.html + "</span></div>"

  # =========================================================================================================
  # Set data from the provided JSON 
  set: (init) ->

    # Clean up current contents
    if @picked.length > 0 
      @picked = []
      @$picked.children("div").remove() 

    return if !init.length
   
    # This might take some time, so display a nice loading animation
    @$picked.addClass "-init"

    init = ({ json : json } for json in init)
   
    # Look for items in static source
    notInStatic = []
    for item in init
      for it2 in @static 
        if @eq it2.json, item.json 
          item.html = it2.html
          break;
      if !("html" of item)
        notInStatic.push item.json

    # Call this function on the data from the dynamic source
    next = (fromDynamic) =>

      # Display all items that have some HTML 
      html = []
      for item in init
        # One of the non-static items : look for HTML in dynamic
        if !("html" of item) 
          for it2 in fromDynamic
            if @eq it2.json, item.json 
              item = it2
              break
        if "html" of item
          @picked.push item 
          html.push @render item
      @$field.before html.join "" 

      # Done ! Restore valid component state
      @onSave()
      @$picked.removeClass "-init"
      @checkMax() 

    # Call "next" on the appropriate data
    if notInStatic.length > 0 && @dynamic
      to_endpoint @dynamic, notInStatic, (data) ->
        next(if "list" of data then data.list else []) 
    else
      next []

  # ==========================================================================================================
  # Move the selection line through the result set
  select: (d) ->
    @selectedPickable = Math.min(@pickable.length-1, Math.max(0, @selectedPickable + d))
    @$pickable.find(".-s").removeClass "-s"
    @$pickable.children(":eq(" + @selectedPickable + ")").addClass "-s"

  # ==========================================================================================================
  # Determine if the maximum number of elements has been picked
  checkMax: () ->
    return if !@maximumPicked
    @$picked.toggleClass "-maxed", @maximumPicked <= @picked.length

  # ==========================================================================================================
  # Pick the current element
  pick: () ->

    return if @selectedPickable >= @pickable.length

    # Perform the actual picking
    item = @pickable[@selectedPickable]
    @picked.push item
    @$field.val("").before(@render item) 
    @checkMax() 

    # Cause list to be re-filtered and re-displayed
    @displayedQuery = null 
    @internalFocus = true  
    @$field.focus()    

    # Fire save event
    @onSave()

  # ==========================================================================================================
  # Remove an element from the picked element list
  unpick: (pos) ->
    pos = pos || @picked.length - 1 if (!pos is 0) 
    @picked.splice(pos,1)
    @$picked.children(":eq(" + pos + ")").remove()
    @checkMax() 
    @onSave()
    @buildPickable()
