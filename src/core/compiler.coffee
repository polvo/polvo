_ = require 'lodash'
fs = require 'fs'
filesize = require 'filesize'

files = require './files'
dirs = require '../utils/dirs'
config = require '../utils/config'
minify = require '../utils/minify'

# prefix = ";(function(){"
prefix = """;(function(){
  function require(path, parent){
    // console.log('::: require', path, parent);

    if(parent)
      path = require.mods[parent].aliases[path]
    
    var mod;
    if(!(mod = require.mods[path]).exports)
      mod.call(this, (mod.exports = {}), require.local(path), mod);

    return mod.exports;
  }

  require.mods = {}

  require.local = function( path ){
    return function( id ) { return require( id, path ); }
  }

  require.register = function(path, mod, aliases){
    // console.log('::: registered', path);
    require.mods[path] = mod;
    mod.aliases = aliases;
  }

  """

sufix = "})()"

build = exports.build = ->
  exports.build_js true
  exports.build_css true


exports.minify = ->
  exports.build_js()
  exports.build_css()

  uncompressed = fs.readFileSync config.output.js
  fs.writeFileSync config.output.js, minify.js uncompressed.toString()

  # TODO: minify css
  # ......

exports.build_js = (notify) ->
  all = _.filter files.files, type: 'js'
  merged = (each.wrapped for each in all).join '\n'

  buffer = prefix
  buffer += "\n"
  buffer += merged
  buffer += "\n"
  buffer += "require('#{config.boot}');"
  buffer += "\n"
  buffer += sufix

  fs.writeFileSync config.output.js, buffer
  exports.notify_js() if notify

exports.build_css = (notify) ->
  all = _.filter files.files, type: 'css'
  merged = (each.compiled for each in all).join '\n'
  fs.writeFileSync config.output.css, merged
  exports.notify_css() if notify

exports.notify_css = ->
  # TODO add show css filesize
  relative = dirs.relative config.output.css
  console.log "✓ #{relative}".green

exports.notify_js = ->
  fsize = filesize (fs.statSync config.output.js).size
  relative = dirs.relative config.output.js
  console.log "✓ #{relative} (#{fsize})".green
