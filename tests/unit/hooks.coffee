fsu = require 'fs-util'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'

# listing all modes for further cleanup
lib = path.join __dirname, '..', '..', 'lib'
mods = fsu.find lib, /\.js/

# clear cache between all tests
afterEach ->

  # clean up all mods cache
  for m in mods
    mod = require.resolve m
    delete require.cache[mod]

  # clean file's state after each test
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