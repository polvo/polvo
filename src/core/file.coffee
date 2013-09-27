fs = require 'fs'
path = require 'path'

_ = require 'lodash'

dirs = require '../utils/dirs'
plugins = require '../utils/plugins'
scan = require '../scanner/scan'
config = require '../utils/config'
notify = require '../utils/notifier'
MicroEvent = require '../event/microevent'

{argv} = require '../cli'
{error, warn, info, debug} = require('../utils/logger')('core/file')

prefix = "require.register('~path', function(require, module, exports){"
sufix = "}, ~deps);"


module.exports = class File extends MicroEvent

  initialized: false

  raw: null
  filepath: null
  relativepath: null
  outputpath: null

  id: null
  type: null
  output: null

  compiled: null
  source_map: null
  source_map_offset: null

  dependents: null
  dependencies: null
  aliases: null

  is_partial: no

  compiler: null

  constructor:(@filepath)->
    @relativepath = dirs.relative @filepath
    @compiler = @get_compiler()
    @compiler.config = config
    {@type, @output} = @compiler
    @is_partial = @compiler.partials is on and @compiler.is_partial @filepath

  init:->
    if @is_partial and not @initialized
        @initialized = true
        return

      @refresh()

  refresh:->
    @raw = fs.readFileSync @filepath, "utf-8"
    @compile =>
      @scan_deps()
      @make_aliases()
      @wrap()
      @emit 'refresh:dependents', @dependents

  compile:( done )->
    return done() if @is_partial

    @compiler.compile @filepath, @raw, not argv.release
      , (err)=>
        error dirs.relative(@filepath), '-', err

      , (@compiled, @source_map)=>
        if @compiler.type is 'template' and config.output.html?
          for input in config.input
            if ~@filepath.indexOf(input)
              relative = @filepath.replace input, ''
              break

          @outputpath = path.join config.output.html, relative
          @outputpath = @outputpath.replace @compiler.ext, '.html'
          @outputpath = path.join dirs.pwd, @outputpath

          unless argv.release
            notify @outputpath

          fs.writeFileSync @outputpath, @compiled

        done()

  wrap:->
    if @output is 'css'
      @wrapped = @compiled
    if @output is 'js'
      id = @relativepath.replace @compiler.ext, ''
      @wrapped = prefix.replace '~path', id
      @wrapped += "\n"
      @wrapped += @compiled
      @wrapped += "\n"
      @wrapped += sufix.replace '~deps', JSON.stringify @aliases

  scan_deps:->

    if @type is 'script'
      @dependents = []
      @dependencies = scan.dependencies @filepath, @compiled
      @emit 'new:dependencies', (location for id, location of @dependencies)

    else if (@type is 'template' or @type is 'style')
      @dependencies = {}
      return @dependents = [] if not @is_partial
      @dependents = scan.dependents @, @filepath, @compiled

  make_aliases:->
    @aliases = {}
    for id, depath of @dependencies when depath?
      @aliases[id] = dirs.relative(depath).replace /\.[^\.]+$/, ''

  get_compiler:->
    for plugin in plugins
      if plugin.ext.test @filepath
        return plugin 