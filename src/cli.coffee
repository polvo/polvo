optimist = require 'optimist'
version = require './utils/version'
colors = require 'colors'

module.exports = class Cli

  argv: null
  options: null

  optimis = null
  usage = null
  examples = null

  constructor:( @options )->
    do @configure
    do @init

    @argv = optimis.argv

  configure:->
    usage = """
      Polvo #{('v' + version).grey}
      #{'Polyvalent cephalopod mollusc'.grey}

      #{'Usage:'}
        polvo [#{'options'.green}] [#{'params'.green}]
    """

    examples = """
      Examples:
        polvo -ws
        polvo -ws -b ./your/app/folder -j ./your/app/folder/config.polvo
    """

  help:->
    "#{optimis.help()}\n#{examples}"

  init:->

    inject = []
    for key, val of @options
      if key.length is 1
        inject = inject.concat "-#{key}", val
      else
        inject = inject.concat "--#{key}", val

    optimis = optimist( process.argv.concat inject ).usage( usage )
      .alias('w', 'watch')
      .describe('w', "Start watching/compiling in dev mode")
      
      .alias('c', 'compile')
      .describe('c', "Compile project in development mode")

      .alias('r', 'release')
      .describe('r', "Compile project in release mode")

      .alias('s', 'server')
      .describe('s', "Serves project statically, options in config file")

      .alias('j', 'config')
      .string( 'j' )
      .describe('j', "Config file formatted as a json-string")

      .alias( 'f', 'config-file' )
      .string( 'f' )
      .describe('f', "Path to a different config file")

      .alias('v', 'version')
      .describe('v', 'Show Polvo\'s version')

      .alias('h', 'help')
      .describe('h', 'Shows this help screen')