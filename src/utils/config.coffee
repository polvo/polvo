path = require 'path'
fs = require 'fs'

yml = require 'js-yaml'
dirs = require './dirs'

{error, warn, info, debug} = require('./log')('utils/config')

parse_config = ( config_file ) ->
  config = require config_file

  for dirpath, index in config.input
    config.input[index] = path.join dirs.pwd, dirpath

  if config.output.js
    config.output.js = path.join dirs.pwd, config.output.js

  if config.output.css
    config.output.css = path.join dirs.pwd, config.output.css

  if config?.server?.root
    config.server.root = path.join dirs.pwd, config.server.root

  if config.minify?
    config.minify.js = config.minify.js ? true
    config.minify.css = config.minify.css ? true
  else
    config.minify = js: true, css: true

  config

polvo_yml = path.join dirs.pwd, "polvo.yml"

if fs.existsSync polvo_yml
  config = parse_config polvo_yml
else
  config = null
  error "Config file #{'polvo.yml'.bold} not found in ~> #{dirs.pwd}"
  process.exit()

module.exports = config