fsu = require 'fs-util'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

# clear cache between all tests
afterEach ->
  mods = [
    '../../lib/utils/plugins'
    '../../lib/utils/config'
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

  clean()


# keeps fixtures always unchanged, reverting changes made by tests
backup_files = []
backup_dirs = []

before ->
  for file in fsu.find path.join(__dirname, '..', 'fixtures'), /.+/, true
    if fs.lstatSync(file).isDirectory()
      backup_dirs.push file
    else
      backup_files.push path: file, raw: fs.readFileSync(file).toString()

after clean = ->
  # roll back all fiels to its original state
  for file in backup_files
    fs.writeFileSync file.path, file.raw

  # removing created dirs
  for dir in fsu.find path.join(__dirname, '..', 'fixtures'), /.+/, true
    continue unless fs.existsSync dir
    if fs.lstatSync(dir).isDirectory() and dir not in backup_dirs
      fsu.rm_rf dir

  # remove also newly crated files
  for file in fsu.find path.join(__dirname, '..', 'fixtures'), /.+/
    unless _.find backup_files, {path:file}
      fs.unlinkSync file