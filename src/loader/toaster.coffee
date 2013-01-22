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

# initialize global require / define
require = -> Toaster.process 'require', [].slice.call arguments
define = -> Toaster.process 'define', [].slice.call arguments