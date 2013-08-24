(require 'source-map-support').install
  handleUncaughtExceptions: false

module.exports = (options = {}, on_data, on_error)->
  global.cli_options = options
  global.__stdout = on_data
  global.__stderr = on_error

  version = require './utils/version'
  log = require('./utils/log')('polvo')
  Cli = require './cli'

  {error, warn, info, debug, log} = log
  {argv} = cli = new Cli

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