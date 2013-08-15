fs = require 'fs'
path = require 'path'

dirs = require '../utils/dirs'
plugins = require '../utils/plugins'
scan = require '../scanner/scan'
MicroEvent = require '../event/microevent'

prefix = "require.register('~path', function(exports, require, module){"
sufix = "}, ~deps);"


module.exports = class File extends MicroEvent

  raw: null
  filepath: null
  relativepath: null

  id: null
  type: null
  deps: null
  aliases: null

  uncompiled: null
  compiled: null
  map: null

  compiled: null
  src_map: null

  compiler: null

  constructor:(@filepath)->
    @relativepath = dirs.relative @filepath
    @compiler = @get_compiler()
    @type = @compiler.type

  init:->
    @refresh()

  refresh:->
    @raw = fs.readFileSync @filepath, "utf-8"
    @compile =>
      @scan_deps()
      @make_aliases()
      @wrap()

  compile:( done )->
    @compiler.compile @filepath, @raw, ( @compiled, @map )=> done?(@)

  wrap:->
    if @type is 'css'
      @wrapped = @compiled
    if @type is 'js'
      id = @relativepath.replace @compiler.ext, ''
      @wrapped = prefix.replace '~path', id
      @wrapped += "\n"
      @wrapped += @compiled
      @wrapped += "\n"
      @wrapped += sufix.replace '~deps', JSON.stringify @aliases

  scan_deps:->
    @deps = scan @filepath, @compiled
    @emit 'deps', (location for id, location of @deps)


  make_aliases:->
    @aliases = {}
    for id, depath of @deps
      @aliases[id] = dirs.relative(depath).replace /\.[^\.]+$/, ''

  get_compiler:->
    for plugin in plugins
      if plugin.ext.test @filepath
        return plugin 