(require 'source-map-support').install
  handleUncaughtExceptions: false

module.exports = (options = {}, io)->

  global.cli_options = options
  global.__stdout = io?.out or null
  global.__stderr = io?.err or null
  global.__nocolor = io?.nocolor or null

  cli = require './cli'
  version = require './utils/version'
  logger = require('./utils/logger')('polvo')

  argv = cli.argv()
  {error, warn, info, debug, log} = logger

  if argv.version
    return log version

  else if argv.compile or argv.watch or argv.release

    config = require('./utils/config').parse()

    if config?
      compiler = require './core/compiler'

      if argv.server and config?
        server = require './core/server'
      
      if argv.compile or argv.watch
        compiler.build()
        server() if argv.server
      
      else if argv.release
        compiler.release()
        server() if argv.server

  else
    log cli.help()

module.exports.close = ->
  files = require './core/files'
  files.close_watchers()