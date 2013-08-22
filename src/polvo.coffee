(require 'source-map-support').install
  handleUncaughtExceptions: false

version = require './utils/version'

Cli = require './cli'

module.exports = (options)->

  {argv} = cli = new Cli options

  if argv.version
    return console.log version

  console.log 'Initializing..'.grey

  if argv.compile or argv.watch or argv.release
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

  console.log cli.help()