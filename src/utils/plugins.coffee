_ = require 'lodash'

path = require 'path'
util = require 'util'

dirs = require '../utils/dirs'

polvo = require path.join dirs.root, 'package.json'
app = require path.join dirs.pwd, 'package.json'

mods = []

for dep of polvo.dependencies
  dep = require path.join dirs.root, 'node_modules', dep
  mods.push dep if dep.polvo and dep not in mods

for dep of app.dependencies
  dep = require path.join dirs.pwd, 'node_modules', dep
  mods.push dep if dep.polvo and dep not in mods

module.exports = mods