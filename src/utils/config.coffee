path = require 'path'
fs = require 'fs'
util = require 'util'

require 'js-yaml'
dirs = require './dirs'
cli = require '../cli'

{error, warn, info, debug} = require('./log')('utils/config')

exports.parse = ->

  argv = cli.argv()

  if dirs.pwd()?
    if argv['config-file']?
      yml = path.join dirs.pwd(), argv['config-file']
    else
      yml = path.join dirs.pwd(), "polvo.yml"

  unless fs.existsSync yml
    error 'Config file not found ~> ', yml
    return null

  if fs.statSync( yml ).isDirectory()
    error 'Config file\'s path is a directory  ~> ', yml
    return null
  else
    config = require yml

  # pwd
  unless fs.existsSync dirs.pwd()
    return null

  # server
  if argv.server

    if config?.server?

      config.server.port ?= 3000
      if config.server?.root
        root = config.server.root = path.join dirs.pwd(), config.server.root
        unless fs.existsSync root
          error 'Server\'s root dir does not exist ~>', root
          return null
      else
        error 'Server\'s root not set in in config file ~>', root
        return null

    else
      error 'Server\'s config not set in config file'
      return null

  # input
  if config?.input? and config.input.length
    for dirpath, index in config.input
      tmp = config.input[index] = path.join dirs.pwd(), dirpath
      unless fs.existsSync tmp
        error 'Input dir does not exist ~>', dirs.relative tmp
        return null
  else
    error 'You need at least one input dir in config file'
    return null

  # output
  if config?.output?

    if config.output.js?
      config.output.js = path.join dirs.pwd(), config.output.js
      tmp = path.dirname config.output.js
      unless fs.existsSync tmp
        error 'JS\'s output dir does not exist ~>', dirs.relative tmp
        return null

    if config.output.css?
      config.output.css = path.join dirs.pwd(), config.output.css
      tmp = path.dirname config.output.css
      unless fs.existsSync tmp
        error 'CSS\'s output dir does not exist ~>', dirs.relative tmp
        return null

  else
    error 'You need at least one output in config file'
    return null

  # mapping
  if config.mappings?
    for name, location of config.mappings
      tmp = config.mappings[name] = path.join dirs.pwd(), location
      unless fs.existsSync tmp
        error "Mapping dir for '#{name}' does not exist ~>", dirs.relative tmp
        return null

  # minify
  if config.minify?
    config.minify.js = config.minify.js ? true
    config.minify.css = config.minify.css ? true
  else
    config.minify = js: true, css: true

  config