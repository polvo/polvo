jade = require 'jade'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Jade

  @EXT = /(\/)([^\/_]+)(\.jade)$/m

  @compile:( file, after_compile )->
    try
      compiled = jade.compile @raw,
        filename: file.absolute_path
        client: true
        compileDebug: false
    catch err
      # catches and shows it, and abort the compilation
      return error err.message
    
    after_compile compiled

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '$1$2.js'