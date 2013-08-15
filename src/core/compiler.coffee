_ = require 'lodash'
fs = require 'fs'
filesize = require 'filesize'

files = require './files'
dirs = require '../utils/dirs'
config = require '../utils/config'
minify = require '../utils/minify'

prefix = ";(function(){"
sufix = "})()"

exports.build = ->
  save_js()
  fsize = filesize (fs.statSync config.output.js).size
  relative = dirs.relative config.output.js
  console.log "✓ #{relative} (#{fsize})".green

  save_css()

exports.minify = ->
  save_js()

  uncompressed = fs.readFileSync config.output.js
  fs.writeFileSync config.output.js, minify.js uncompressed.toString()

  size = filesize (fs.statSync config.output.js).size
  relative = dirs.relative config.output.js
  console.log "✓ #{relative} (minified=#{size})".green

  save_css()


save_js = ->
  all = _.filter files.files, type: 'js'
  merged = (each.wrapped for each in all).join '\n'

  buffer = prefix
  buffer += "\n"
  buffer += merged
  buffer += "\n"
  buffer += sufix

  fs.writeFileSync config.output.js, buffer

save_css = ->
  all = _.filter files.files, type: 'css'
  merged = (each.compiled for each in all).join '\n'

  fs.writeFileSync config.output.css, merged
  relative = dirs.relative config.output.css
  console.log "✓ #{relative}".green