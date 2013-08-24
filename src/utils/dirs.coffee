path = require 'path'

Cli = require '../cli'
{argv} = cli = new Cli

module.exports = 
  root: path.join __dirname, '..', '..'
  pwd: path.resolve argv.base or '.'
  relative:(filepath)->
    if ~filepath.indexOf(@pwd)
      filepath.replace "#{@pwd}/", ''
    else
      path.relative @pwd, filepath