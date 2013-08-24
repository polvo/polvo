path = require 'path'
fs = require 'fs'

Cli = require '../cli'
log = require('./log')('polvo')

{argv} = cli = new Cli
{error, warn, info, debug, log} = log

resolve_base = ->
  unless fs.existsSync base = path.resolve argv.base or '.'
    error 'Dir informed with [--base] option doesn\'t exist ~>', base
    return null
  
  return base

module.exports = 
  root: path.join __dirname, '..', '..'
  pwd: resolve_base()
  relative:(filepath)->
    if filepath.indexOf(@pwd) is 0
      filepath.replace "#{@pwd}/", ''
    else
      path.relative @pwd, filepath