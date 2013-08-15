path = require 'path'

module.exports = 
  root: path.join __dirname, '..', '..'
  pwd: path.resolve '.'
  relative:(filepath)->
    filepath.replace "#{@pwd}/", ''