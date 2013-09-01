fsu = require 'fs-util'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

# clear cache between all tests
afterEach ->
  mods = [
    '../../lib/utils/plugins'
    '../../lib/core/compiler'
    '../../lib/core/file'
    '../../lib/core/files'
    '../../lib/core/server'

    '../../lib/scanner/resolve'
    '../../lib/scanner/scan'
  ]

  for m in mods
    mod = require.resolve m
    delete require.cache[mod]


# keeps fixtures always unchanged, reverting changes made by tests
backup = []
before ->
  for file in fsu.find path.join(__dirname, '..', 'fixtures'), /.+/
    backup.push path: file, raw: fs.readFileSync(file).toString()

after ->
  # roll back all fiels to its original state
  for file in backup
    fs.writeFileSync file.path, file.raw

  # remove also newly crated files
  for file in fsu.find path.join(__dirname, '..', 'fixtures'), /.+/
    unless _.find backup, {path:file}
      fs.unlinkSync file