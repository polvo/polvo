util = require 'util'
colors = require 'colors'

# dirs module is required above to avoid circular-loop
dirs = null
Cli = require '../cli'

alias = ''
{argv} = cli = new Cli

log_to_stdout = ( args ) ->
  args = [].concat args

  if process.send and not argv.stdio
    process.send channel: 'stdout', msg: args.join ' '
  else if __stdout?
    __stdout args.join(' ').stripColors
  else
    console.log.apply null, args

log_to_stderr = ( args )->
  args = [].concat args

  if process.send and not argv.stidio
    process.send channel: 'stderr', msg: args.join ' '
  else if __stderr?
    __stderr args.join(' ').stripColors
  else
    console.error.apply null, args

module.exports = (_alias)->
  dirs = require './dirs'
  alias = (_alias or alias).grey
  module.exports

module.exports.error = (msg, args...)->
  log_to_stderr ['error'.bold.red, msg.grey].concat args

module.exports.warn = (msg, args...)->
  log_to_stderr [' warn'.bold.yellow, msg.grey].concat args

module.exports.info = (msg, args...)->
  log_to_stdout = [' info'.bold.cyan, msg.grey].concat args

module.exports.debug = (msg, args...)->
  log_to_stdout = [alias.inverse, 'debug'.magenta, msg.grey].concat args

module.exports.log = (args...)->
  log_to_stdout args

module.exports.file = 
  created:( filepath )->
    log_to_stdout "+ #{dirs.relative filepath}".green

  changed:( filepath )->
    log_to_stdout "• #{dirs.relative filepath}".yellow

  deleted:( filepath )->
    log_to_stdout "- #{dirs.relative filepath}".red

  compiled:( filepath )->
    log_to_stdout "✓ #{dirs.relative filepath}".cyan