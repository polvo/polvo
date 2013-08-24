path = require 'path'
fs = require 'fs'

yml = require 'js-yaml'
dirs = require './dirs'
Cli = require '../cli'

{error, warn, info, debug} = require('./log')('utils/config')
{argv} = cli = new Cli


parse_config = ( cpath ) ->
  config = require cpath

  # pwd
  unless fs.existsSync dirs.pwd
    return null

  # server
  if argv.server

    if config?.server?

      config.server.port ?= 3000
      if config.server?.root
        root = config.server.root = path.join dirs.pwd, config.server.root
        unless fs.existsSync root
          error 'Server\'s root dir doesn\'t exist ~>', root
          return null

    else
      error 'Server\'s config not set in config file ~> ', dirs.relative cpath
      return null

  # input
  if config?.input? and config.input.length
    for dirpath, index in config.input
      tmp = config.input[index] = path.join dirs.pwd, dirpath
      unless fs.existsSync tmp
        error 'Input dir does not exist ~>', dirs.relative tmp
        return null
  else
    error 'You need at least one input dir in your config file'
    return null

  # output
  if config?.output?

    if config.output.js?
      config.output.js = path.join dirs.pwd, config.output.js
      tmp = path.dirname config.output.js
      unless fs.existsSync tmp
        error 'JS\'s output dir does not exist ~>', dirs.relative tmp
        return null

    if config.output.css?
      config.output.css = path.join dirs.pwd, config.output.css
      tmp = path.dirname config.output.css
      unless fs.existsSync
        error 'CSS\'s output dir does not exist ~>', dirs.relative tmp
        return null

  else
    error 'You need at least one output in your config file'
    return null

  # mapping
  if config.mappings?
    for name, location of config.mappings
      tmp = config.mappings[name] = path.join dirs.pwd, location
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


config = null
if dirs.pwd?
  if argv['config-file']?
    polvo_yml = path.join dirs.pwd, argv['config-file']
  else
    polvo_yml = path.join dirs.pwd, "polvo.yml"

  if fs.existsSync polvo_yml
    config = parse_config polvo_yml
  else
    error 'Config file not found ~> ', polvo_yml


module.exports = config