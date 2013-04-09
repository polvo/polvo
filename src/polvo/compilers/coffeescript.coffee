require('source-map-support').install()

cs = require 'coffee-script'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Coffeescript

  @EXT = /\.(lit)?(coffee)(\.md)?$/m

  AMD_WRAPPER = """
  // rendered with stylus
  define(['require', 'exports', 'module'], function(require, exports, module){
    ~code
  });"""

  @compile:( file, after_compile )->
    try
      compiled = cs.compile file.raw, bare: 1
    catch err
      # catches and shows it, and abort the compilation
      msg = err.message.replace '"', '\\"'
      msg = "#{msg.white} @ " + "#{@filepath}".bold.red
      return error msg

    wrapped = AMD_WRAPPER.replace '~code', compiled
    after_compile wrapped

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '.js'