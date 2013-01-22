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