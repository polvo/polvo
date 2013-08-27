optimist = require 'optimist'
colors = require 'colors'

version = require './utils/version'

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

$argv = process.argv
optimistic = null

exports.help = ->
  "#{optimistic.help()}\n#{examples}"

exports.argv = (opts)->

  if opts?
    options = opts
  else if cli_options?
    options = cli_options

  injection = []
  for key, val of (options or {})
    injection.push if key.length is 1 then "-#{key}" else "--#{key}"
    injection.push "#{val}"

  process.argv = $argv.slice(0).concat injection

  optimistic = optimist( process.argv ).usage( usage )
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

    .alias('b', 'base')
    .describe('b', 'Path to app\'s root folder (when its not the current)')
    .string( 'b' )

    .alias('v', 'version')
    .boolean('v')
    .describe('v', 'Show Polvo\'s version')

    .alias('h', 'help')
    .boolean('h')
    .describe('h', 'Shows this help screen')

    # .describe('stdio', 'Pipe stdio when forking `polvo` as a child process')
    # .boolean( 'stdio' )


  return optimistic.argv

exports.argv()