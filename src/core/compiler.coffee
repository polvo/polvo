_ = require 'lodash'
fs = require 'fs'
path = require 'path'
filesize = require 'filesize'

files = require './files'
server = require './server'

cli = require '../cli'
dirs = require '../utils/dirs'
config = require '../utils/config'
minify = require '../utils/minify'
sourcemaps = require '../utils/sourcemaps'
logger = require('../utils/logger')('core/compiler')


argv = cli.argv()

{error, warn, info, debug} = logger
log_compiled = logger.file.compiled


# prefix
prefix = ";(function(){"

# cjs loader
loader_path = path.join dirs.root, 'src', 'core', 'helpers', 'loader.js'
loader = fs.readFileSync loader_path, 'utf-8'
loader = loader.replace '~MAPPINGS', JSON.stringify config.mappings

# auto reload
io_path = path.join dirs.root, 'node_modules', 'socket.io', 'node_modules'
io_path = path.join io_path, 'socket.io-client', 'dist', 'socket.io.js'
reloader_path = loader_path.replace 'loader.js', 'reloader.js'

auto_reload = fs.readFileSync io_path, 'utf-8'
auto_reload += fs.readFileSync reloader_path, 'utf-8'

source_maps_header = """
/*
//@ sourceMappingURL=data:application/json;charset=utf-8;base64,~MAP
*/
"""

# sufix
sufix = '})()'


compilers = {}



exports.build = ->
  compilers = {}
  exports.build_js true
  exports.build_css true


exports.release = ->
  exports.build_js()
  exports.build_css()

  if config.minify.js
    uncompressed = fs.readFileSync config.output.js
    fs.writeFileSync config.output.js, minify.js uncompressed.toString()
    exports.notify_js()

  if config.minify.css
    uncompressed = fs.readFileSync config.output.css
    fs.writeFileSync config.output.css, minify.css uncompressed.toString()
    exports.notify_css()

exports.build_js = (notify) ->
  files.files = _.sortBy files.files, 'filepath'

  all = _.filter files.files, output: 'js'
  return unless all.length
  
  unless config.output.js?
    error 'JS not saved, you need to set the js output in your config file'
    return

  helpers = {}
  merged = []

  offset = 0

  for each in all when each.wrapped?
    continue if each.is_partial

    # saving compiled contents and line count
    js = each.wrapped
    linesnum = js.split('\n').length

    # storing compiled code in merged array
    merged.push js

    # updating file's offset info for source maps concatenation
    each.source_map_offset = offset
    offset += linesnum

    # getting compiler
    comp = each.compiler
    comp_name = comp.name
    if not helpers[comp_name]? and (helper = comp.fetch_helpers?())?
      helpers[comp_name] or= helper

  # merging helpers
  helpers = (v for k, v of helpers)
  merged = merged.join '\n'

  # starting empty buffer
  buffer = ''

  if argv.server and not argv.release and argv.autoreload isnt false
    buffer += "\n// POLVO :: AUTORELOAD\n"
    buffer += auto_reload

  buffer += prefix
  buffer += '\n// POLVO :: HELPERS\n'
  buffer += helpers

  buffer += "\n// POLVO :: LOADER\n"
  buffer += loader
  buffer += "\n// POLVO :: MERGED FILES\n"

  start = buffer.split('\n').length
  for each in all
    each.source_map_offset += start
  sourcemaps.assemble all

  buffer += merged

  buffer += "\n// POLVO :: INITIALIZER\n"
  buffer += "require('#{config.boot}');"
  buffer += "\n"
  buffer += source_maps_header.replace '~MAP', sourcemaps.get_assembled_64()
  buffer += sufix

  fs.writeFileSync config.output.js, buffer

  server.reload 'js'
  exports.notify_js() if notify

exports.build_css = (notify) ->
  files.files = _.sortBy files.files, 'filepath'

  all = _.filter files.files, output: 'css'
  return unless all.length

  unless config.output.css?
    error 'CSS not saved, you need to set the css output in your config file'
    return

  merged = []
  for each in all
    continue if each.is_partial
    merged.push each.compiled

  merged = merged.join '\n'

  fs.writeFileSync config.output.css, merged
  server.reload 'css'
  exports.notify_css() if notify

exports.notify_css = ->
  fsize = filesize (fs.statSync config.output.css).size
  log_compiled "#{config.output.css} (#{fsize})"

exports.notify_js = ->
  fsize = filesize (fs.statSync config.output.js).size
  log_compiled "#{config.output.js} (#{fsize})"