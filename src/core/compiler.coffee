_ = require 'lodash'
fs = require 'fs'

files = require './files'
config = require '../utils/config'
minify = require '../utils/minify'

wrapper = """
  ;(function(){
    ~mods
  })()
"""

exports.build = ->
  save_js()
  save_css()

exports.minify = ->
  save_js()
  uncompressed = fs.readFileSync config.output.js
  fs.writeFileSync config.output.js, minify.js uncompressed.toString()
  
  save_css()
  

save_js = ->
  all = _.filter files.files, type: 'js'
  merged = (each.compiled for each in all).join '\n'

  fs.writeFileSync config.output.js, wrapper.replace '~mods', merged
  console.log 'Compiled', config.output.js

save_css = ->
  all = _.filter files.files, type: 'css'
  merged = (each.compiled for each in all).join '\n'

  fs.writeFileSync config.output.css, merged
  console.log 'Compiled', config.output.css