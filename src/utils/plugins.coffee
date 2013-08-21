_ = require 'lodash'

fs = require 'fs'
path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'

plugins = []

scan = (manifest_path)->
  return if not fs.existsSync manifest_path

  manifest = require manifest_path
  for plugin of manifest.dependencies
    try
      plugin = require path.join dirs.root, 'node_modules', plugin
      plugins.push plugin if plugin.polvo
    catch err
      continue

scan path.join dirs.root, 'package.json'
scan path.join dirs.pwd, 'package.json'

module.exports = plugins