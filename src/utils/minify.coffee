uglify = require 'uglify-js'

exports.js = ( uncompressed )->
  ast = uglify.parse uncompressed
  stream = uglify.OutputStream()
  ast.print stream
  compiled = stream.toString()

exports.css = ( uncompressed )->
  uncompressed