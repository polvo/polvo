(require 'source-map-support').install
  handleUncaughtExceptions: false

version = require './utils/version'
compiler = require './core/compiler'
server = require './core/server'

Cli = require './cli'

module.exports = (options)->

  {argv} = cli = new Cli options

  if argv.version
    return console.log version

  if argv.compile or argv.watch
    compiler.build()
    server() if argv.server
    return

  if argv.release
    compiler.release()
    server() if argv.server
    return

  console.log cli.help()