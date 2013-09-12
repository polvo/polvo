util = require 'util'
colors = require 'colors'

# dirs module is required above to avoid circular-loop
dirs = null
{argv} = require '../cli'

log_to_stdout = ( args ) ->
  args = [].concat args

  # if process.send and not argv.stdio
  #   process.send channel: 'stdout', msg: args.join ' '
  if __stdout?
    msg = args.join(' ')
    msg = msg.stripColors if __nocolor? and __nocolor
    __stdout msg
  else
    console.log.apply null, args

log_to_stderr = ( args )->
  args = [].concat args

  # if process.send and not argv.stidio
  #   process.send channel: 'stderr', msg: args.join ' '
  if __stderr?
    msg = args.join(' ')
    msg = msg.stripColors if __nocolor? and __nocolor
    __stderr msg
  else
    console.error.apply null, args

module.exports = (alias = '')->
  dirs = require './dirs'

  error: (msg, args...)->
    log_to_stderr ['error'.bold.red, msg.grey].concat args

  warn: (msg, args...)->
    log_to_stderr ['warn'.bold.yellow, msg.grey].concat args

  info: (msg, args...)->
    log_to_stdout ['info'.bold.cyan, msg.grey].concat args

  debug: (msg, args...)->
    args = ['debug'.magenta, msg.grey].concat args
    args.unshift alias.inverse if alias isnt ''
    log_to_stdout args

  log: (msg, args...)->
    log_to_stdout [msg].concat args


  file: 
    created:( filepath )->
      log_to_stdout "+ #{dirs.relative filepath}".green

    changed:( filepath )->
      log_to_stdout "• #{dirs.relative filepath}".yellow

    deleted:( filepath )->
      log_to_stdout "- #{dirs.relative filepath}".red

    compiled:( filepath )->
      log_to_stdout "✓ #{dirs.relative filepath}".cyan