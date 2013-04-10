require('source-map-support').install()

stylus = require 'stylus'
nib = require 'nib'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Stylus

  @EXT = /(\/)([^\/_]+)(\.styl)$/m

  AMD_WRAPPER = """
  // Compiled by Polvo, using Stylus
  define(['require', 'exports', 'module'], function(require, exports, module){
    var style = module.exports = document.createElement('style');
    style.appendChild(document.createTextNode('~css'));
    return style;
  });"""

  @compile = ( file, after_compile )->
    stylus( file.raw )
      .set( 'filename', file.absolute_path )
      .use( nib() )
      .import( 'nib' )
      .render (err, css)=>
        return error err if err?

        wrapped = AMD_WRAPPER.replace '~css', (css.replace /\n|\r|\s/g, '')
        after_compile wrapped

  @translate_ext = ( filepath )->
    return filepath.replace @EXT, '$1$2.js'

  @strip_ext:( filepath )->
    return filepath.replace @EXT, '$1$2'