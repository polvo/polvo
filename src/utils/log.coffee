util = require 'util'
colors = require 'colors'

module.exports = class Log
  alias: null

  constructor:(alias = null)->
    @alias = alias.grey

  error:(msg, args...)=>
    output = ['error'.red, msg.grey].concat args
    console.log.apply null, output

  warn:(msg, args...)=>
    output = [' warn'.yellow, msg.grey].concat args
    console.log.apply null, output

  info:(msg, args...)=>
    output = [' info'.cyan, msg.grey].concat args
    console.log.apply null, output

  debug:(msg, args...)=>
    output = [@alias, 'debug'.magenta, msg.grey].concat args
    console.log.apply null, output