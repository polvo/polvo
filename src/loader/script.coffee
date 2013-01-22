class Script

  cached = {}

  id: null
  el: null
  url: null
  done: null
  error: null

  constructor:( @id, @done, @error, timeout )->
    setTimeout =>
      @load()
    , timeout

  load:()->

    if @id[0] is ':'
      @id = @id.substr 1
      
      if Toaster.MAP[@id]?
        @url = Toaster.MAP[@id]
      else
        @url = @id

    unless /^http/m.test @url 
      reg = new RegExp( "(^#{Toaster.BASE_URL.replace '/', '\\/'})" )
      @url = "#{Toaster.BASE_URL}#{@id}" unless reg.test @id

    # adds extension if needed
    if (@url.indexOf '.js') < 0
      @url += '.js'


    # console.log 'load..... >> ', @url
    if cached[ @url ] is true
      return setTimeout @done, 1

    # creates element for loading the script
    @el = document.createElement 'script'
    @el.type = 'text/javascript'
    @el.charset = 'utf-8'
    @el.async = true
    @el.setAttribute 'data-id', @id
    @el.src = @url
    @el.onerror = @error

    # IE - onload
    if @el.readyState
      @el.onreadystatechange = (ev) =>
        if @el.readyState is 'loaded' or @el.readyState is 'complete'
          @el.onreadystatechange = null
          @internal_done ev

    # OTHERS - onload
    else
      @el.onload = ( ev )=>
        @internal_done ev

    # attach to head
    head = (document.getElementsByTagName 'head')[0]
    head.insertBefore @el, head.lastChild

  internal_done: ( ev )->
    # console.log '...loaded << ' + @url
    cached[ @url ] = true
    @done (@el.getAttribute 'data-id'), @el.src