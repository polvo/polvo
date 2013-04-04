require('source-map-support').install()

uglify = require 'uglify-js'

module.exports = class MinifyUtil
  @min:( contents )->
    
    ast = uglify.parse contents
    stream = uglify.OutputStream()
    ast.print stream
    compiled = stream.toString()