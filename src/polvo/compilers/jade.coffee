path = require 'path'
fs = require 'fs'
jade = require 'jade'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Jade

  @NAME = 'jade'
  @TYPE = 'template'
  @EXT = /(\/)([^\/_]+)(\.jade)$/m

  AMD_WRAPPER = """
  // Compiled by Polvo, using Jade
  define(['require', 'exports', 'module'], function(require, exports, module){
    return exports.module = ~code
  });"""

  @compile:( file, after_compile )->
    try
      compiled = jade.compile file.raw,
        filename: file.absolute_path
        client: true
        compileDebug: true
    catch err
      # catches and shows it, and abort the compilation
      return error err.message
    
    wrapped = AMD_WRAPPER.replace '~code', compiled.toString()
    after_compile wrapped

  @fetch_helpers:->
    filepath = path.join __dirname, '..', '..', '..', 'node_modules', 'jade'
    filepath = path.join filepath, 'runtime.js'
    fs.readFileSync filepath, 'utf-8'

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '$1$2.js'

  @strip_ext:( filepath )->
    return filepath.replace @EXT, '$1$2'