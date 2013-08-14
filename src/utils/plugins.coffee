path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'

manifest = require path.join dirs.pwd, 'package.json'

mods = []
for dep of manifest.dependencies
  dep = require path.join dirs.pwd, 'node_modules', dep
  mods.push dep if dep.polvo

module.exports = mods