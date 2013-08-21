_ = require 'lodash'

path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'

mods = []

polvo_manifest = path.join dirs.root, 'package.json'
if fs.existsSync polvo_manifest
  polvo = require polvo_manifest
  for dep of polvo.dependencies
    try
      dep = require path.join dirs.root, 'node_modules', dep
    catch err
      continue

    mods.push dep if dep.polvo and dep not in mods

app_manifest = path.join dirs.pwd, 'package.json'
if fs.existsSync app_manifest
  app = require app_manifest
  for dep of app.dependencies
    try
      dep = require path.join dirs.pwd, 'node_modules', dep
    catch err
      continue

    mods.push dep if dep.polvo and dep not in mods

module.exports = mods