require('source-map-support').install()

cs = require 'coffee-script'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Coffeescript

  @EXT = /\.(lit)?(coffee)(\.md)?$/m

  AMD_WRAPPER = """
  // rendered with stylus
  define('~name', [~deps], function(){
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

    name = file.relative_path.replace @EXT, ''
    wrapped = AMD_WRAPPER.replace '~name', name
    wrapped = wrapped.replace '~deps', ''
    wrapped = wrapped.replace '~code', compiled

    after_compile wrapped

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '.js'