path = require 'path'

module.exports = 
  root: path.join __dirname, '..', '..'
  pwd: path.resolve '.'
  relative:(filepath)->
    if ~filepath.indexOf(@pwd)
      filepath.replace "#{@pwd}/", ''
    else
      path.relative @pwd, filepath