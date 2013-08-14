require 'js-yaml'
path = require 'path'
dirs = require './dirs'

config = require path.join dirs.pwd, "polvo.yml"

for dirpath, index in config.input
  config.input[index] = path.join dirs.pwd, dirpath

if config.output.js
  config.output.js = path.join dirs.pwd, config.output.js

if config.output.css
  config.output.css = path.join dirs.pwd, config.output.css

module.exports = config