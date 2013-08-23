(require 'source-map-support').install
  handleUncaughtExceptions: false

version = require './utils/version'
log = require('./utils/log')('polvo')

{error, warn, info, debug, log} = log


Cli = require './cli'

module.exports = (options)->

  {argv} = cli = new Cli options

  if argv.version
    return log version

  if argv.compile or argv.watch or argv.release
    log 'Initializing..'.grey
    compiler = require './core/compiler'

  if argv.server
    server = require './core/server'

  if argv.compile or argv.watch
    compiler.build()
    server() if argv.server
    return

  if argv.release
    compiler.release()
    server() if argv.server
    return

  log cli.help()