(require 'source-map-support').install
  handleUncaughtExceptions: false

module.exports = (options = {}, io)->
  global.cli_options = options
  global.__stdout = io?.out or null
  global.__stderr = io?.err or null

  version = require './utils/version'
  config = require './utils/config'
  log = require('./utils/log')('polvo')
  Cli = require './cli'

  {error, warn, info, debug, log} = log
  {argv} = cli = new Cli

  if argv.version
    return log version

  else if argv.compile or argv.watch or argv.release

    if config?
      compiler = require './core/compiler'

      if argv.server and config?
        server = require './core/server'
      
      if argv.compile or argv.watch
        compiler.build()
        server() if argv.server
      
      else if argv.release
        console.log 'merda'
        compiler.release()
        server() if argv.server

  else
    log cli.help()