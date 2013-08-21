_ = require 'lodash'
fs = require 'fs'
filesize = require 'filesize'

files = require './files'
dirs = require '../utils/dirs'
config = require '../utils/config'
minify = require '../utils/minify'

prefix = """;(function(){
  function require(path, parent){
    var m, realpath;

    if(parent)
      realpath = require.mods[parent].aliases[path];
    else
      realpath = path;

    if(!realpath)
      realpath = require.map( path );
    
    if(!(m = require.mods[realpath]))
    {
      console.error('Module not found: ', path);
      return null
    }
    
    if(!m.init)
    {
      m.factory.call(this, require.local(realpath), m.module, m.module.exports);
      m.init = true;
    }

    return m.module.exports;
  }

  require.mods = {}

  require.local = function( path ){
    return function( id ) { return require( id, path ); }
  }

  require.register = function(path, mod, aliases){
    require.mods[path] = {
      factory: mod,
      aliases: aliases,
      module: {exports:{}}
    };
  }

  require.maps = #{JSON.stringify config.mappings};
  require.map = function(path) {
    for(var map in require.maps)
      if(path.indexOf(map) == 0)
        return require.maps[map] + path;
    return null;
  }
  """

sufix = '})()'

compilers = {}

build = exports.build = ->
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
  
  helpers = {}
  merged = []

  for each in all
    continue if each.is_partial

    merged.push each.wrapped

    comp = each.compiler
    comp_name = comp.name

    if not helpers[comp_name]? and (helper = comp.fetch_helpers?())?
      helpers[comp_name] or= helper

  helpers = (v for k, v of helpers)
  merged = merged.join '\n'

  buffer = '// POLVO :: HELPERS\n'
  buffer += helpers
  buffer += "\n// POLVO :: LOADER\n"
  buffer += prefix
  buffer += "\n// POLVO :: MERGED FILES\n"
  buffer += merged
  buffer += "\n// POLVO :: INITIALIZER\n"
  buffer += "require('#{config.boot}');"
  buffer += "\n"
  buffer += sufix

  fs.writeFileSync config.output.js, buffer
  exports.notify_js() if notify

exports.build_css = (notify) ->
  files.files = _.sortBy files.files, 'filepath'

  all = _.filter files.files, output: 'css'
  merged = []

  for each in all
    continue if each.is_partial
    merged.push each.compiled

  merged = merged.join '\n'

  fs.writeFileSync config.output.css, merged
  exports.notify_css() if notify

exports.notify_css = ->
  fsize = filesize (fs.statSync config.output.css).size
  relative = dirs.relative config.output.css
  console.log "✓ #{relative} (#{fsize})".cyan

exports.notify_js = ->
  fsize = filesize (fs.statSync config.output.js).size
  relative = dirs.relative config.output.js
  console.log "✓ #{relative} (#{fsize})".cyan