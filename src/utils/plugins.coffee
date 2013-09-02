_ = require 'lodash'

fs = require 'fs'
path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'
{error, info} = require('../utils/logger')('utils/plugins')

plugins = []
registered = {}

get_plugin_manifest = ( plugin )->
  current = path.dirname require.resolve plugin
  while current isnt '/'
    manifest = path.join current, 'package.json'
    if fs.existsSync manifest
      return manifest
    else
      current = path.join current, '..'

scan = (folder)->

  manifest_path = path.join folder, 'package.json'
  manifest = require manifest_path

  for plugin of manifest.dependencies
    absolute = get_plugin_manifest plugin

    pfolder = path.join folder, 'node_modules', plugin
    pmanifest = require path.join pfolder, 'package.json'

    if pmanifest.polvo and not registered[pmanifest.name]
      registered[pmanifest.name] = true
      plugins.push require plugin

scan path.join dirs.root()

app_json = path.join dirs.pwd(), 'package.json'
if fs.existsSync app_json
  scan dirs.pwd()
else
  info 'app doesn\'t have a `package.json` file, loading built-in plugins only'

module.exports = plugins