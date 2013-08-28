_ = require 'lodash'

fs = require 'fs'
path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'
{info} = require('../utils/logger')('utils/plugins')

plugins = []
registered = {}

scan = (manifest_path)->
  manifest = require manifest_path

  for plugin of manifest.dependencies
    pmanifest = require "#{plugin}/package.json"

    if pmanifest.polvo and not registered[pmanifest.name]
      registered[pmanifest.name] = true
      plugins.push require plugin

scan path.join dirs.root(), 'package.json'

app_json = path.join dirs.pwd(), 'package.json'
if fs.existsSync app_json
  scan app_json
else
  info 'app doesn\'t have a `package.json` file, loading built-in plugins only'

module.exports = plugins