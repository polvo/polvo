jade = require 'jade'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Jade

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

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '$1$2.js'

  @strip_ext:( filepath )->
    return filepath.replace @EXT, '$1$2'