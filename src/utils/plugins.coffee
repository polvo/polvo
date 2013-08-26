_ = require 'lodash'

fs = require 'fs'
path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'

plugins = []
registered = {}

scan = (manifest_path)->
  return unless fs.existsSync manifest_path

  manifest = require manifest_path

  for plugin of manifest.dependencies
    pmanifest = require "#{plugin}/package.json"

    if pmanifest.polvo and not registered[pmanifest.name]
      registered[pmanifest.name] = true
      plugins.push require plugin

scan path.join dirs.root(), 'package.json'
scan path.join dirs.pwd(), 'package.json'

module.exports = plugins