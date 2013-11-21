fs = require 'fs'
path = require 'path'

_ = require 'lodash'

dirs = require '../utils/dirs'
plugins = require '../utils/plugins'
scan = require '../scanner/scan'

MicroEvent = require '../event/microevent'

{argv} = require '../cli'
{error, warn, info, debug} = require('../utils/logger')('core/file')

prefix = "require.register('~path', function(require, module, exports){"
sufix = "}, ~deps);"


module.exports = class File extends MicroEvent

  raw: null
  filepath: null
  relativepath: null

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
    {@type, @output} = @compiler
    @is_partial = @compiler.partials is on and @compiler.is_partial @filepath

  init:->
    @refresh()

  refresh:->
    @raw = fs.readFileSync @filepath, "utf-8"
    @parse_conditionals()

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
        done()

  parse_conditionals:()->
    reg = /^.+polvo:if([\s\S]+?)polvo:fi.*$/gm;
    buffer = []
    copy = @raw

    while (res = reg.exec @raw)
      before = res[0]
      after = @parse_conditional_block before
      copy = copy.replace before, after

    @raw = copy

  parse_conditional_block:(block)->

    buffer = '' 
    passed = 0
    capturing = false

    for line in block.split '\n'

      # if, elif
      if /polvo:(if|elif)/.test line

        cond = line.match(/(\w+)=(\w+)/)
        [key, value] = cond.slice 1

        capturing = process.env[key] is value
        passed++ if capturing

        continue

      # else
      else if /polvo:else/.test(line)
        capturing = passed is 0
        continue

      # fi
      else if /polvo:fi/.test line
        return buffer

      # lines
      else if capturing
        buffer += line

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