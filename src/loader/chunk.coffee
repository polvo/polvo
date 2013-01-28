class Chunk

  @chunks_list = []
  @chunks = {}

  factored: null

  constructor:( @type, @id, @deps, @factory, @non_amd = false )->
    if @id? and @id[0] is ':'
      @id = (@id.substr 1)

    Chunk.chunks_list.push @

  # notify all loaded-but-not-yet-executed chunks that a new file has
  # finish loading, so the execution can occur
  @notify_all = ( loaded )->
    console.log "----------- #{loaded} "
    for chunk in @chunks_list
      chunk.exec loaded

  # execute the factory method and stores it in a `factored` property
  exec:( loaded )->

    console.log ">>>>> "
    console.log "id: #{@id}"
    console.log "factored: #{@factored?}"
    # console.log "factory: #{@factory?}"
    # console.log "loaded: #{@_is_subtree_loaded()}"
    # console.log "non_amd: #{@non_amd}"

    # if was already factored, just returns it
    return @factored if @factored? or @non_amd

    console.log 1

    # abort if dependencies hasn't finish loading
    return unless @_is_subtree_loaded()

    console.log 2

    # # abort if there's no factory function/object reference
    # return unless @factory?

    console.log 3

    console.log '\t <<---- go to go'

    # loop through all dependencies
    refs = []
    for dep in @deps

      if dep[0] is ':'
        continue

      # collects the factored ref
      current = Chunk.chunks[ dep ]
      mod = current.exec( loaded )
      if mod?
        refs.push mod

    # if factory is a method, execute it and keep the returned ref
    if @factory instanceof Function
      @factored = @factory.apply null, refs

    # otherwise if it's a object literal, just stores it
    else if typeof @factory is 'object'
      @factored = @factory

    return @factored

  # checks if all sub deps for this item has finish loading
  _is_subtree_loaded:->
    status = true
    for dep in @deps

      dep = dep.substr 1 if dep[0] is ':'

      if @id is 'app'
        console.log ">>>>>>>>>>>>>"
        console.log "dep: #{dep}"
        console.log "def: #{Chunk.chunks[ dep ]}"
        console.log "ven: #{Chunk.chunks[ dep ].non_amd}"
        console.log "fac: #{Chunk.chunks[ dep ].factored}"
        console.log "<<<<<<<<<<<<<"

      if Chunk.chunks[ dep ]?
        dep = Chunk.chunks[ dep ]
        if dep.factored is null and dep.non_amd is false
          return false
      else
        return false

    return status