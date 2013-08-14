fs = require 'fs'

plugins = require '../utils/plugins'

wrapper = """
    require.register('~filepath', function(require, exports, module){
    ~code
    });
  """


module.exports = class File

  raw: null
  filepath: null

  id: null
  type: null
  deps: null

  uncompiled: null
  compiled: null
  map: null

  compiled: null
  src_map: null

  compiler: null

  constructor:(@filepath)->
    @deps = []
    @compiler = get_compiler()
    @type = @compiler.type
    @refresh()

  refresh:->
    @raw = fs.readFileSync @filepath, "utf-8"
    @resolve_deps @deps = []
    @compile()

  compile:( done )->
    @compiler.compile @filepath, @raw, ( compiled, @map, @uncompiled )=>
      if @type is 'css'
        @compiled = compiled
      else if @type is 'js'
        @compiled = wrapper.replace('~filepath', @filepath)
        @compiled = @compiled.replace('~code', compiled)
      
      done?(@)

  resolve_deps = (deps) ->
    

  get_compiler = ->
    return plugin if plugin.ext.test @filepath for plugin in plugins