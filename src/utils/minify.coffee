uglify = require 'uglify-js'
cleancss = require 'clean-css'

exports.js = ( uncompressed )->
  ast = uglify.parse uncompressed
  stream = uglify.OutputStream()
  ast.print stream
  compiled = stream.toString()

exports.css = ( uncompressed )->
  cleancss.process uncompressed