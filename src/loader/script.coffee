class Script

  started = {}
  cached = {}

  id: null
  el: null
  url: null
  done: null
  error: null

  constructor:( @id, @url, @done, @error, timeout, @is_non_amd )->
    setTimeout =>
      @load()
    , timeout

  load:()->

    if Toaster.MAP[@id]?
      @url = Toaster.MAP[@id]
    else
      @url = @id

    unless /^http/m.test @url 
      reg = new RegExp( "(^#{Toaster.BASE_URL.replace '/', '\\/'})" )
      @url = "#{Toaster.BASE_URL}#{@url}" unless reg.test @url

    # adds extension if needed
    if (@url.indexOf '.js') < 0
      @url += '.js'

    if cached[ @url ] is true
      return @done @id, @url
    else if started[@url]?
      return

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

    started[@url] = true

    # attach to head
    # console.log 'load..... >> ', @url
    head = (document.getElementsByTagName 'head')[0]
    head.insertBefore @el, head.lastChild

  internal_done: ( ev )->
    # console.log '...loaded << ' + @url
    cached[ @url ] = true
    @done @id, @el.src, @is_non_amd