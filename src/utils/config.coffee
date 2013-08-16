yml = require 'js-yaml'
path = require 'path'
dirs = require './dirs'

config = require path.join dirs.pwd, "polvo.yml"

for dirpath, index in config.input
  config.input[index] = path.join dirs.pwd, dirpath

if config.output.js
  config.output.js = path.join dirs.pwd, config.output.js

if config.output.css
  config.output.css = path.join dirs.pwd, config.output.css

if config.minify?
  config.minify.js = config.minify.js ? true
  config.minify.css = config.minify.css ? true
else
  config.minify = js: true, css: true

module.exports = config