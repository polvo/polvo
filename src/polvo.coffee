(require 'source-map-support').install
  handleUncaughtExceptions: false

module.exports = (options, io)->

  if options?
    global.cli_options = options

  if io?
    global.__stdout = io.out
    global.__stderr = io.err
    global.__nocolor = io.nocolor

  cli = require './cli'
  version = require './utils/version'
  logger = require('./utils/logger')('polvo')

  {argv} = cli
  {error, warn, info, debug, log} = logger

  if argv.version
    return log version

  else if argv.compile or argv.watch or argv.release

    config = require './utils/config'

    if config?
      compiler = require './core/compiler'

      if argv.server and config?
        server = require './core/server'
      
      if argv.compile or argv.watch
        compiler.build()
        server() if argv.server
      
      else if argv.release
        compiler.release ->
          server() if argv.server

  else
    log cli.help()

  module.exports

module.exports.close = ->
  files = require './core/files'
  server = require './core/server'

  files.close_watchers()
  server.close()

module.exports.read_config = ->
  require './utils/config'