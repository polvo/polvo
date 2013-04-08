stylus = require 'stylus'
nib = require 'nib'

{log,debug,warn,error} = require './../utils/log-util'

module.exports = class Stylus

  @EXT = /(\/)([^\/_]+)(\.styl)$/m

  @compile:( file, after_compile )->
    stylus( file.raw )
      .set( 'filename', file.absolute_path )
      .use( nib() )
      .import( 'nib' )
      .render (err, css)->
        return error err if err?
        after_compile css

  @translate_ext:( filepath )->
    return filepath.replace @EXT, '$1$2.css'