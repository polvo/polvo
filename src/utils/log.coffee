util = require 'util'
colors = require 'colors'

alias = ''

module.exports = (_alias)->
  alias = (_alias or alias).grey
  module.exports

module.exports.error = (msg, args...)->
    output = ['error'.red, msg.grey].concat args
    console.log.apply null, output

module.exports.warn = (msg, args...)->
    output = [' warn'.yellow, msg.grey].concat args
    console.log.apply null, output

module.exports.info = (msg, args...)->
    output = [' info'.cyan, msg.grey].concat args
    console.log.apply null, output

module.exports.debug = (msg, args...)->
    output = [alias.inverse, 'debug'.magenta, msg.grey].concat args
    console.log.apply null, output