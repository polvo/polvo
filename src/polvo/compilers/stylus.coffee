require('source-map-support').install()

stylus = require 'stylus'
nib = require 'nib'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Stylus

  @EXT = /(\/)([^\/_]+)(\.styl)$/m

  AMD_WRAPPER = """
  // rendered with stylus
  define('~name',[], function(){
    var style = document.createElement('~css');
    style.appendChild(document.createTextNode(''));
    return style;
  });"""

  @compile = ( file, after_compile )->
    stylus( file.raw )
      .set( 'filename', file.absolute_path )
      .use( nib() )
      .import( 'nib' )
      .render (err, css)=>
        return error err if err?
        name = file.relative_path.replace @EXT, '$1$2'
        wrapped = (AMD_WRAPPER.replace '~name', name)
        wrapped = wrapped.replace '~css', (css.replace /\n|\r|\s/g, '')
        after_compile wrapped

  @translate_ext = ( filepath )->
    return filepath.replace @EXT, '$1$2.js'