optimist = require 'optimist'
version = require './utils/version'
colors = require 'colors'

module.exports = class Cli

  argv: null
  options: null

  optimis = null
  usage = null
  examples = null

  constructor:->
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
        polvo -c
        polvo -cs
        polvo -w
        polvo -ws
        polvo -wsf custom-config-file.yml
    """

  help:->
    "#{optimis.help()}\n#{examples}"

  init:->

    for key, val of cli_options
      process.argv.push if key.length is 1 then "-#{key}" else "--#{key}"
      process.argv.push "#{val}"

    optimis = optimist( process.argv ).usage( usage )
      .alias('w', 'watch')
      .boolean( 'w' )
      .describe('w', "Start watching/compiling in dev mode")
      
      .alias('c', 'compile')
      .boolean( 'c' )
      .describe('c', "Compile project in development mode")

      .alias('r', 'release')
      .boolean( 'r' )
      .describe('r', "Compile project in release mode")

      .alias('s', 'server')
      .boolean( 's' )
      .describe('s', "Serves project statically, options in config file")

      .alias( 'f', 'config-file' )
      .string( 'f' )
      .describe('f', "Path to a different config file")

      .describe('stdio', 'Pipe stdio when forking `polvo` as a child process')
      .boolean( 'f' )

      .describe('base', 'Path to app\'s root folder (when its not the current)')
      .string( 'base' )

      .alias('v', 'version')
      .boolean('v')
      .describe('v', 'Show Polvo\'s version')

      .alias('h', 'help')
      .boolean('h')
      .describe('h', 'Shows this help screen')