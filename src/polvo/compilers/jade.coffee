require('source-map-support').install()

jade = require 'jade'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Jade

  @EXT = /(\/)([^\/_]+)(\.jade)$/m

  AMD_WRAPPER = """
  // rendered with jade
  define('~name',[~deps], function(){
    return ~code
  });"""

  @compile:( file, after_compile )->
    try
      compiled = jade.compile file.raw,
        filename: file.absolute_path
        client: true
        compileDebug: false
    catch err
      # catches and shows it, and abort the compilation
      return error err.message
    
    name = file.relative_path.replace @EXT, '$1$2'
    wrapped = AMD_WRAPPER.replace '~name', name
    wrapped = wrapped.replace '~deps', ''
    wrapped = wrapped.replace '~code', compiled.toString()

    after_compile wrapped

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '$1$2.js'