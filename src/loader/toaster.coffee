require = -> Toaster.process 'require', [].slice.call arguments
define = -> Toaster.process 'define', [].slice.call arguments

# ...
# Toaster class
class Toaster
  @last_chunk = null
  @BASE_URL = null
  @MAP = {}

  # ...
  # config toaster
  @config:( options )->
    Toaster.BASE_URL = options.base_url

  # ...
  # layer map
  @map:( layer_map )->
    Toaster.MAP = layer_map

  # ...
  # process all require's and define's calls
  @process = ( type, params, load = true )->

    # first require (inline script) is handled differently (root)
    Toaster.define_chunk 'root' if @last_chunk?

    # format params checking all possible ways
    params = Toaster._name_params type, params

    # creates and stores a new Chunk
    @last_chunk = new Chunk type, params.id, params.deps, params.factory

    # loop through all chunk deps and instantiate a new
    # script instance for loading it
    timeout = 0
    for s in params.deps
      new Script s,

      # onload callback
      (name, url)->

        # define the last instantiated chunk
        Toaster.define_chunk name, url

        # notify everybody that a new chunk was defined
        Chunk.notify_all name

      # on error callback
      , ( e )->
        console.error e

      # timeout
      , ++timeout

  # ...
  # define last chunk
  @define_chunk = (name, url)->

    # inject id into the chunk
    if @last_chunk?
      @last_chunk.id = name = (@last_chunk.id or name)
    else
      @last_chunk = new Chunk 'require', name, [], {}

    if @last_chunk.id[0] is ':'
      @last_chunk.id = @last_chunk.id.substr 1

    # define it int the Chunk.chunks property
    Chunk.chunks[@last_chunk.id] = @last_chunk

    # resets the last reference
    @last_chunk = null

  # ...
  # Sort all params in all possible ways
  @_name_params:( type, params )->

    # initialize empty hash for holding params
    sorted = id: null, deps: null, factory: null

    switch type

      when 'require'

        # require(deps)
        # require(deps, factory)
        sorted.deps = params[0]
        sorted.factory = params[1] or null

      when'define'

        # when defining, factory will be always the last
        sorted.factory = params[params.length-1]

        # define(id, deps, factory)
        if params.length is 3
          sorted.id = params[0]
          sorted.deps = [].concat params[1]

        # define(deps, factory)
        else if params.length is 2
          sorted.deps = [].concat params[0]

        # define(factory)
        else if params.length = 1
          sorted.deps = []

    sorted


# ...
# Chunk class
class Chunk

  @chunks_list = []
  @chunks = {}

  factored: null

  constructor:( @type, @id, @deps, @factory )->
    @id = (@id.substr 1) if @id? and @id[0] is ':'
    Chunk.chunks_list.unshift @

  # notify all loaded-but-not-yet-executed chunks that a new file has
  # finish loading, so the execution can occur
  @notify_all = ( loaded )->
    for chunk in @chunks_list
      if chunk.factored is null and chunk._is_subtree_loaded()
        chunk.exec()

  # execute the factory method and stores it in a `factored` property
  exec:->
    # if was already factored, just returns it
    return @factored if @factored?

    # abort if dependencies hasn't finish loading
    return unless @_is_subtree_loaded()

    # abort if there's no factory function/object reference
    return unless @factory?

    # loop through all dependencies
    refs = []
    for dep in @deps

      continue if dep[0] is ':'

      # collects the factored ref
      current = Chunk.chunks[ dep ]
      refs.push mod if (mod = current.exec())?

    # if factory is a method, execute it and keep the returned ref
    if @factory instanceof Function
      @factored = @factory.apply null, refs

    # otherwise if it's a object literal, just stores it
    else if typeof @factory is 'object'
      @factored = @factory
    else
      @factored = false

  # checks if all sub deps for this item has finish loading
  _is_subtree_loaded:->
    status = true
    for dep in @deps

      dep = dep.substr 1 if dep[0] is ':'
      # console.log '------------ checking dep: ' + dep

      if Chunk.chunks[ dep ]?
        dep = Chunk.chunks[ dep ]
        # console.log 'NOT NULL'
        if dep.factored is null
          # console.log 'NOT FACTORED'
          return false
        else
          # console.log 'YES FACTORED'
          status = true

        # console.log 'YES DEFINED!'
      else
        # console.log '++++++++++ NOT DEFiNED ' + dep
        return false
    return status


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