path = require 'path'
fs = require 'fs'

{error, warn, info, debug, log} = require('./logger')('utils/dirs')
{argv} = require '../cli'

exports.root = path.join __dirname, '..', '..'

if argv.base?
  unless fs.existsSync (pwd = path.resolve argv.base)
    error 'Dir informed with [--base] option doesn\'t exist ~>', argv.base
    pwd = null
else
  pwd = path.resolve '.'

exports.pwd = pwd

exports.relative = (filepath)->
  path.relative exports.pwd, filepath