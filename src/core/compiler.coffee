_ = require 'lodash'
fs = require 'fs'

fsu = require 'fs-util'
path = require 'path'

files = require './files'
server = require './server'

{argv} = require '../cli'
dirs = require '../utils/dirs'
config = require '../utils/config'
minify = require '../utils/minify'
sourcemaps = require '../utils/sourcemaps'
notify = require '../utils/notifier'


# prefix
prefix = ";(function(){"

# helpers folder path
helpers_path = path.join dirs.root, 'src', 'core', 'helpers'

# cjs loader
loader_path = path.join helpers_path, 'loader.js'
loader = fs.readFileSync loader_path, 'utf-8'
loader = loader.replace '~ALIASES', JSON.stringify config.alias

# split loader
split_loader_path = path.join helpers_path, 'split.loader.js'
split_loader = fs.readFileSync split_loader_path, 'utf-8'

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


exports.release = (done) ->
  jss = exports.build_js()
  exports.build_css()
  htmls = _.filter files.files, type: 'template', is_partial: off

  pending = 0
  after = -> done?() if --pending is 0

  if config.minify.js

    for js in jss
      pending++

      # resolving right path for --split files
      if /__split__/.test js
        js = path.join path.dirname(config.output.js), js

      uncompressed = fs.readFileSync js
      fs.writeFileSync js, minify.js uncompressed.toString()

  if config.minify.css and fs.existsSync config.output.css
    pending++
    uncompressed = fs.readFileSync config.output.css
    fs.writeFileSync config.output.css, minify.css uncompressed.toString()
  
  if config.minify.html?
    for file in htmls
      uncompressed = fs.readFileSync file.filepath
      fs.writeFileSync file.filepath, minify.html uncompressed.toString()

  for file in htmls
    pending++
    uncompressed = fs.readFileSync file.outputpath
    fs.writeFileSync file.outputpath, minify.html uncompressed.toString()
    notify file.outputpath, after

  notify js, after
  notify config.output.css, after

exports.build_js = (_notify) ->

  files.files = _.sortBy files.files, 'filepath'

  all = _.filter files.files, output: 'js'
  
  if config.output.html?
    all = _.filter files.files, type: 'script'

  return unless all.length

  unless config.output.js?
    error 'JS not saved, you need to set the js output in your config file'
    return

  if argv.split
    split_paths = build_js_split all, _notify
  else
    split_paths = []

  helpers = {}
  merged = []

  offset = 0

  for each in all
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

  if argv.server and not argv.release
    buffer += "\n// POLVO :: AUTORELOAD\n"
    buffer += auto_reload

  buffer += prefix
  buffer += '\n// POLVO :: HELPERS\n'
  buffer += helpers

  buffer += "\n// POLVO :: LOADER\n"
  buffer += loader

  start = buffer.split('\n').length
  for each in all
    each.source_map_offset += start
  sourcemaps.assemble all

  unless argv.split
    buffer += "\n// POLVO :: MERGED FILES\n"
    buffer += merged

  buffer += "\n// POLVO :: INITIALIZER\n"

  boot = "require('#{config.boot}');"
  if argv.split
    tmp = split_loader.replace '~SRCS', JSON.stringify(split_paths)
    tmp = tmp.replace '~BOOT', boot
    buffer += tmp
  else
    buffer += boot

  unless argv.split
    buffer += "\n"
    buffer += source_maps_header.replace '~MAP', sourcemaps.get_assembled_64()
  
  buffer += sufix

  fs.writeFileSync config.output.js, buffer

  if not argv.release
    server.reload 'js'

  if _notify
    notify config.output.js

  [config.output.js].concat split_paths

exports.build_css = (_notify) ->
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
  notify config.output.css if _notify


get_split_base_dir = (files)->
  buffer = []
  tokens = {}

  for file in files
    for part in file.filepath.split path.sep
      continue if tokens[part]

      start = buffer.concat(part).join path.sep
      all = true

      for f in files
        all and = f.filepath.indexOf(start) is 0

      if all
        tokens[part] = buffer.push part
      else
        return buffer.join(path.sep)

build_js_split = (files, _notify)->
  base = get_split_base_dir files
  paths = []

  for file in files
    filename = path.basename(file.filepath).replace file.compiler.ext, '.js'
    filefolder = path.dirname file.filepath

    httpath = path.join '/__split__', filefolder.replace(base, ''), filename
    output = path.join path.dirname(config.output.js), httpath

    paths.push httpath
    buffer = file.wrapped

    if file.source_map?
      
      map = JSON.parse(file.source_map)
      map.file = path.basename output
      map.sources = ['/' + dirs.relative file.filepath]
      map.sourcesContent = [file.raw]

      map64 = new Buffer(JSON.stringify(map)).toString 'base64'

      buffer += '\n'
      buffer += source_maps_header.replace '~MAP', map64

    folder = path.dirname output
    fsu.mkdir_p folder unless fs.existsSync folder
    fs.writeFileSync output, buffer
    
    if _notify
      notify output

  paths