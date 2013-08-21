_ = require 'lodash'

path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'

plugins = []

scan = (manifest)->
  for plugin of manifest.dependencies
    try
      plugin = require path.join dirs.root, 'node_modules', plugin
    catch err
      continue

polvo_manifest = path.join dirs.root, 'package.json'
if fs.existsSync polvo_manifest
  scan require polvo_manifest

app_manifest = path.join dirs.pwd, 'package.json'
if fs.existsSync app_manifest
  scan require app_manifest

module.exports = plugins